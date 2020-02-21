# frozen_string_literal: true

class Projects::ValueVsCostController < Projects::ApplicationController
  include RendersNotes
  include ToggleSubscriptionAction
  include IssuableActions
  include ToggleAwardEmoji
  include IssuableCollections
  include IssuesCalendar
  include SpammableActions
  include RecordUserLastActivity

  def issue_except_actions
    %i[index]
  end

  def set_issuables_index_only_actions
    %i[index]
  end

  prepend_before_action(only: [:index]) { authenticate_sessionless_user!(:rss) }

  before_action :check_issues_available!
  before_action :issue, unless: ->(c) { c.issue_except_actions.include?(c.action_name.to_sym) }

  before_action :set_issuables_index, if: ->(c) { c.set_issuables_index_only_actions.include?(c.action_name.to_sym) }

  before_action do
    push_frontend_feature_flag(:vue_issuable_sidebar, project.group)
  end

  around_action :allow_gitaly_ref_name_caching, only: [:discussions]

  respond_to :html

  def index
    @issues = @issuables

    respond_to do |format|
      format.html
      format.atom { render layout: 'xml.atom' }
      format.json do
        render json: {
          html: view_to_html_string("projects/issues/_issues"),
          labels: @labels.as_json(methods: :text_color)
        }
      end
    end
  end

  def calendar
    render_issues_calendar(@issuables)
  end

  def can_create_branch
    can_create = current_user &&
      can?(current_user, :push_code, @project) &&
      @issue.can_be_worked_on?

    respond_to do |format|
      format.json do
        render json: { can_create_branch: can_create, suggested_branch_name: @issue.suggested_branch_name }
      end
    end
  end

  def sorting_field
    Issue::SORTING_PREFERENCE_FIELD
  end

  # rubocop: disable CodeReuse/ActiveRecord
  def issue
    return @issue if defined?(@issue)

    # The Sortable default scope causes performance issues when used with find_by
    @issuable = @noteable = @issue ||= @project.issues.includes(author: :status).where(iid: params[:id]).reorder(nil).take!
    @note = @project.notes.new(noteable: @issuable)

    return render_404 unless can?(current_user, :read_issue, @issue)

    @issue
  end
  # rubocop: enable CodeReuse/ActiveRecord
  alias_method :subscribable_resource, :issue
  alias_method :issuable, :issue
  alias_method :awardable, :issue
  alias_method :spammable, :issue

  def spammable_path
    project_issue_path(@project, @issue)
  end

  def authorize_create_merge_request!
    render_404 unless can?(current_user, :push_code, @project) && @issue.can_be_worked_on?
  end

  def issue_params
    params.require(:issue).permit(
      *issue_params_attributes,
      sentry_issue_attributes: [:sentry_issue_identifier]
    )
  end

  def issue_params_attributes
    %i[
      title
      assignee_id
      position
      description
      confidential
      milestone_id
      due_date
      state_event
      task_num
      lock_version
      discussion_locked
    ] + [{ label_ids: [], assignee_ids: [], update_task: [:index, :checked, :line_number, :line_source] }]
  end

  def reorder_params
    params.permit(:move_before_id, :move_after_id, :group_full_path)
  end

  def store_uri
    if request.get? && !request.xhr?
      store_location_for :user, request.fullpath
    end
  end

  def serializer
    IssueSerializer.new(current_user: current_user, project: issue.project)
  end

  def update_service
    update_params = issue_params.merge(spammable_params)
    Issues::UpdateService.new(project, current_user, update_params)
  end

  def finder_type
    IssuesFinder
  end

  def whitelist_query_limiting
    # Also see the following issues:
    #
    # 1. https://gitlab.com/gitlab-org/gitlab-foss/issues/42423
    # 2. https://gitlab.com/gitlab-org/gitlab-foss/issues/42424
    # 3. https://gitlab.com/gitlab-org/gitlab-foss/issues/42426
    Gitlab::QueryLimiting.whitelist('https://gitlab.com/gitlab-org/gitlab-foss/issues/42422')
  end
end
