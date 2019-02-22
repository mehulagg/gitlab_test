# frozen_string_literal: true

module EE
  module GroupsController
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override

    prepended do
      delegate :group_view_redirect_needed?, :group_view_supports_request_format?, :group_view_url,
               to: :presenter
    end

    override :show
    def show
      if ::Feature.enabled?(:group_overview_security_dashboard) && redirect_to_group_view?
        redirect_to group_view_url(group)
      else
        super
      end
    end

    def group_params_attributes
      super + group_params_ee
    end

    private

    def redirect_to_group_view?
      group_view_supports_request_format? && group_view_redirect_needed?
    end

    def group_params_ee
      [
        :membership_lock,
        :repository_size_limit
      ].tap do |params_ee|
        params_ee << :project_creation_level if current_group&.feature_available?(:project_creation_level)
        params_ee << :file_template_project_id if current_group&.feature_available?(:custom_file_templates_for_namespace)
        params_ee << :custom_project_templates_group_id if License.feature_available?(:custom_project_templates)
      end
    end

    def current_group
      @group
    end

    # NOTE: currently unable to wrap a group in presenter and re-assign @group: SimpleDelegator doesn't substitute
    # the class of a wrapped object; see gitlab-ce/#57299
    def presenter
      strong_memoize(:presenter) do
        group.present(current_user: current_user, request: request, helpers: helpers)
      end
    end
  end
end
