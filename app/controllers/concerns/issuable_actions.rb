# frozen_string_literal: true

module IssuableActions
  extend ActiveSupport::Concern
  include Gitlab::Utils::StrongMemoize

  included do
    before_action :authorize_destroy_issuable!, only: :destroy
    before_action :check_destroy_confirmation!, only: :destroy
    before_action :authorize_admin_issuable!, only: :bulk_update
    before_action only: :show do
      push_frontend_feature_flag(:scoped_labels, default_enabled: true)
    end
    before_action do
      push_frontend_feature_flag(:not_issuable_queries, @project, default_enabled: true)
    end
  end

  def permitted_keys
    [
      :issuable_ids,
      :assignee_id,
      :milestone_id,
      :state_event,
      :subscription_event,
      label_ids: [],
      add_label_ids: [],
      remove_label_ids: []
    ]
  end

  def show
    respond_to do |format|
      format.html do
        @issuable_sidebar = serializer.represent(issuable, serializer: 'sidebar') # rubocop:disable Gitlab/ModuleWithInstanceVariables
        render 'show'
      end

      format.json do
        render json: serializer.represent(issuable, serializer: params[:serializer])
      end
    end
  end

  def update
    @issuable = update_service.execute(issuable) # rubocop:disable Gitlab/ModuleWithInstanceVariables
    respond_to do |format|
      format.html do
        recaptcha_check_if_spammable { render :edit }
      end

      format.json do
        recaptcha_check_if_spammable(false) { render_entity_json }
      end
    end

  rescue ActiveRecord::StaleObjectError
    render_conflict_response
  end

  def realtime_changes
    Gitlab::PollingInterval.set_header(response, interval: 3_000)

    response = {
      title: view_context.markdown_field(issuable, :title),
      title_text: issuable.title,
      description: view_context.markdown_field(issuable, :description),
      description_text: issuable.description,
      task_status: issuable.task_status,
      lock_version: issuable.lock_version
    }

    if issuable.edited?
      response[:updated_at] = issuable.last_edited_at.to_time.iso8601
      response[:updated_by_name] = issuable.last_edited_by.name
      response[:updated_by_path] = user_path(issuable.last_edited_by)
    end

    render json: response
  end

  def destroy
    Issuable::DestroyService.new(issuable.project, current_user).execute(issuable)

    name = issuable.human_class_name
    flash[:notice] = "The #{name} was successfully deleted."
    index_path = polymorphic_path([parent, issuable.class])

    respond_to do |format|
      format.html { redirect_to index_path }
      format.json do
        render json: {
          web_url: index_path
        }
      end
    end
  end

  def check_destroy_confirmation!
    return true if params[:destroy_confirm]

    error_message = "Destroy confirmation not provided for #{issuable.human_class_name}"
    exception = RuntimeError.new(error_message)
    Gitlab::ErrorTracking.track_exception(
      exception,
      project_path: issuable.project.full_path,
      issuable_type: issuable.class.name,
      issuable_id: issuable.id
    )

    index_path = polymorphic_path([parent, issuable.class])

    respond_to do |format|
      format.html do
        flash[:notice] = error_message
        redirect_to index_path
      end
      format.json do
        render json: { errors: error_message }, status: :unprocessable_entity
      end
    end
  end

  def bulk_update
    result = Issuable::BulkUpdateService.new(parent, current_user, bulk_update_params).execute(resource_name)
    quantity = result[:count]

    render json: { notice: "#{quantity} #{resource_name.pluralize(quantity)} updated" }
  end

  # rubocop:disable CodeReuse/ActiveRecord
  def discussions
    notes = NotesFinder.new(current_user, finder_params_for_issuable).execute
                .inc_relations_for_view
                .includes(:noteable)
                .fresh

    if notes_filter != UserPreference::NOTES_FILTERS[:only_comments]
      notes = ResourceEvents::MergeIntoNotesService.new(issuable, current_user).execute(notes)
    end

    notes = prepare_notes_for_rendering(notes)
    notes = notes.select { |n| n.readable_by?(current_user) }
    discussions = discussion_serializer.represent(
      Discussion.build_collection(notes, issuable),
      context: self
    )

    try_stream = Feature.enabled?(:stream_discussions, default_enabled: true)
    hijackable = request.env['rack.hijack?']

    Rails.logger.warn("Streaming on but Rack hijacking off") if try_stream && !hijackable # rubocop:disable Gitlab/RailsLogger

    return render(json: discussions) unless try_stream && hijackable

    stream_chunked_json_array(discussions)
  end
  # rubocop:enable CodeReuse/ActiveRecord

  private

  def stream_chunked_json_array(array)
    request.env['rack.hijack'].call
    stream = request.env['rack.hijack_io']

    stream.write([
      "HTTP/1.1 200 OK",
      "Content-Type: application/json",
      "X-Accel-Buffering: no",
      "Transfer-Encoding: chunked",
      "Cache-Control: no-cache"
    ].join("\r\n") + "\r\n\r\n") # Each header terminated with newline, followed by empty line

    # Chunked encoding gives size in hex, newline, raw data, newline
    count = array.count
    array.each_with_index do |item, index|
      first = (index == 0)
      last = (index + 1 == count)

      data = item.to_json
      size = data.bytesize + 1 # closing brace or interstitial comma
      size += 1 if first # opening brace

      stream.write("#{size.to_s(16)}\r\n") # Size is transmitted in hex
      stream.write("[") if first
      stream.write(data)

      if last
        stream.write("]")
      else
        stream.write(",")
      end

      stream.write("\r\n") # End of chunk. Not included in the count
    end

    stream.write("0\r\n\r\n") # Finish with a zero-length chunk, then empty line
  ensure
    f&.close
    stream&.close
    response.close
  end

  def notes_filter
    strong_memoize(:notes_filter) do
      notes_filter_param = params[:notes_filter]&.to_i

      # GitLab Geo does not expect database UPDATE or INSERT statements to happen
      # on GET requests.
      # This is just a fail-safe in case notes_filter is sent via GET request in GitLab Geo.
      # In some cases, we also force the filter to not be persisted with the `persist_filter` param
      if Gitlab::Database.read_only? || params[:persist_filter] == 'false'
        notes_filter_param || current_user&.notes_filter_for(issuable)
      else
        notes_filter = current_user&.set_notes_filter(notes_filter_param, issuable) || notes_filter_param

        # We need to invalidate the cache for polling notes otherwise it will
        # ignore the filter.
        # The ideal would be to invalidate the cache for each user.
        issuable.expire_note_etag_cache if notes_filter_updated?

        notes_filter
      end
    end
  end

  def notes_filter_updated?
    current_user&.user_preference&.previous_changes&.any?
  end

  def discussion_serializer
    DiscussionSerializer.new(project: project, noteable: issuable, current_user: current_user, note_entity: ProjectNoteEntity)
  end

  def recaptcha_check_if_spammable(should_redirect = true, &block)
    return yield unless issuable.is_a? Spammable

    recaptcha_check_with_fallback(should_redirect, &block)
  end

  def render_conflict_response
    respond_to do |format|
      format.html do
        @conflict = true # rubocop:disable Gitlab/ModuleWithInstanceVariables
        render :edit
      end

      format.json do
        render json: {
          errors: [
            "Someone edited this #{issuable.human_class_name} at the same time you did. Please refresh your browser and make sure your changes will not unintentionally remove theirs."
          ]
        }, status: :conflict
      end
    end
  end

  def authorize_destroy_issuable!
    unless can?(current_user, :"destroy_#{issuable.to_ability_name}", issuable)
      return access_denied!
    end
  end

  def authorize_admin_issuable!
    unless can?(current_user, :"admin_#{resource_name}", parent)
      return access_denied!
    end
  end

  def authorize_update_issuable!
    render_404 unless can?(current_user, :"update_#{resource_name}", issuable)
  end

  def bulk_update_params
    permitted_keys_array = permitted_keys.dup
    permitted_keys_array << { assignee_ids: [] }

    params.require(:update).permit(permitted_keys_array)
  end

  def resource_name
    @resource_name ||= controller_name.singularize
  end

  # rubocop:disable Gitlab/ModuleWithInstanceVariables
  def render_entity_json
    if @issuable.valid?
      render json: serializer.represent(@issuable)
    else
      render json: { errors: @issuable.errors.full_messages }, status: :unprocessable_entity
    end
  end
  # rubocop:enable Gitlab/ModuleWithInstanceVariables

  def serializer
    raise NotImplementedError
  end

  def update_service
    raise NotImplementedError
  end

  def parent
    @project || @group # rubocop:disable Gitlab/ModuleWithInstanceVariables
  end

  # rubocop:disable Gitlab/ModuleWithInstanceVariables
  def finder_params_for_issuable
    {
        target: @issuable,
        notes_filter: notes_filter
    }.tap { |new_params| new_params[:project] = project if respond_to?(:project, true) }
  end
  # rubocop:enable Gitlab/ModuleWithInstanceVariables
end

IssuableActions.prepend_if_ee('EE::IssuableActions')
