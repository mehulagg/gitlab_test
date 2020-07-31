# frozen_string_literal: true

module EE
  module ProjectsHelper
    extend ::Gitlab::Utils::Override

    override :sidebar_settings_paths
    def sidebar_settings_paths
      super + %w[
        audit_events#index
        operations#show
      ]
    end

    override :sidebar_repository_paths
    def sidebar_repository_paths
      super + %w(path_locks)
    end

    override :sidebar_operations_paths
    def sidebar_operations_paths
      super + %w[
        tracings
        feature_flags
      ]
    end

    override :get_project_nav_tabs
    def get_project_nav_tabs(project, current_user)
      nav_tabs = super

      nav_tabs += get_project_security_nav_tabs(project, current_user)

      if can?(current_user, :read_code_review_analytics, project)
        nav_tabs << :code_review
      end

      if can?(current_user, :read_project_merge_request_analytics, project)
        nav_tabs << :merge_request_analytics
      end

      if can?(current_user, :read_feature_flag, project) && !nav_tabs.include?(:operations)
        nav_tabs << :operations
      end

      if project.feature_available?(:issues_analytics) && can?(current_user, :read_project, project)
        nav_tabs << :issues_analytics
      end

      if project.insights_available?
        nav_tabs << :project_insights
      end

      nav_tabs
    end

    override :tab_ability_map
    def tab_ability_map
      tab_ability_map = super
      tab_ability_map[:feature_flags] = :read_feature_flag
      tab_ability_map
    end

    override :default_url_to_repo
    def default_url_to_repo(project = @project)
      case default_clone_protocol
      when 'krb5'
        project.kerberos_url_to_repo
      else
        super
      end
    end

    override :extra_default_clone_protocol
    def extra_default_clone_protocol
      if alternative_kerberos_url? && current_user
        "krb5"
      else
        super
      end
    end

    override :sidebar_operations_link_path
    def sidebar_operations_link_path(project = @project)
      super || project_feature_flags_path(project)
    end

    override :remove_project_message
    def remove_project_message(project)
      return super unless project.adjourned_deletion?

      date = permanent_deletion_date(Time.now.utc)
      _("Removing a project places it into a read-only state until %{date}, at which point the project will be permanently removed. Are you ABSOLUTELY sure?") %
        { date: date }
    end

    def permanent_deletion_date(date)
      (date + ::Gitlab::CurrentSettings.deletion_adjourned_period.days).strftime('%F')
    end

    # Given the current GitLab configuration, check whether the GitLab URL for Kerberos is going to be different than the HTTP URL
    def alternative_kerberos_url?
      ::Gitlab.config.alternative_gitlab_kerberos_url?
    end

    def can_change_push_rule?(push_rule, rule, context)
      return true if push_rule.global?

      can?(current_user, :"change_#{rule}", context)
    end

    def ci_cd_projects_available?
      ::License.feature_available?(:ci_cd_projects) && import_sources_enabled?
    end

    def merge_pipelines_available?
      return false unless @project.builds_enabled?

      @project.feature_available?(:merge_pipelines)
    end

    def merge_trains_available?
      return false unless @project.builds_enabled?

      @project.feature_available?(:merge_trains)
    end

    def sidebar_security_paths
      %w[
        projects/security/configuration#show
        projects/security/sast_configuration#show
        projects/security/vulnerabilities#show
        projects/security/dashboard#index
        projects/on_demand_scans#index
        projects/dast_profiles#index
        projects/dast_site_profiles#new
        projects/dependencies#index
        projects/licenses#index
        projects/threat_monitoring#show
        projects/threat_monitoring#new
      ]
    end

    def sidebar_external_tracker_paths
      %w[
        projects/integrations/jira/issues#index
      ]
    end

    def size_limit_message(project)
      show_lfs = project.lfs_enabled? ? 'including files in LFS' : ''

      "The total size of this project's repository #{show_lfs} will be limited to this size. 0 for unlimited. Leave empty to inherit the group/global value."
    end

    override :membership_locked?
    def membership_locked?
      group = @project.group

      return false unless group

      group.membership_lock? || ::Gitlab::CurrentSettings.lock_memberships_to_ldap?
    end

    def group_project_templates_count(group_id)
      allowed_subgroups = current_user.available_subgroups_with_custom_project_templates(group_id)

      ::Project.in_namespace(allowed_subgroups).count
    end

    def project_security_dashboard_config(project)
      if project.vulnerabilities.none?
        {
          has_vulnerabilities: 'false',
          empty_state_svg_path: image_path('illustrations/security-dashboard_empty.svg'),
          security_dashboard_help_path: help_page_path('user/application_security/security_dashboard/index')
        }
      else
        {
          has_vulnerabilities: 'true',
          project: { id: project.id, name: project.name },
          project_full_path: project.full_path,
          vulnerabilities_endpoint: project_security_vulnerability_findings_path(project),
          vulnerabilities_summary_endpoint: summary_project_security_vulnerability_findings_path(project),
          vulnerabilities_export_endpoint: api_v4_security_projects_vulnerability_exports_path(id: project.id),
          vulnerability_feedback_help_path: help_page_path("user/application_security/index", anchor: "interacting-with-the-vulnerabilities"),
          empty_state_svg_path: image_path('illustrations/security-dashboard-empty-state.svg'),
          no_vulnerabilities_svg_path: image_path('illustrations/issues.svg'),
          dashboard_documentation: help_page_path('user/application_security/security_dashboard/index'),
          not_enabled_scanners_help_path: help_page_path('user/application_security/index', anchor: 'quick-start'),
          no_pipeline_run_scanners_help_path: new_project_pipeline_path(project),
          security_dashboard_help_path: help_page_path('user/application_security/security_dashboard/index'),
          user_callouts_path: user_callouts_path,
          user_callout_id: UserCalloutsHelper::STANDALONE_VULNERABILITIES_INTRODUCTION_BANNER,
          show_introduction_banner: show_standalone_vulnerabilities_introduction_banner?.to_s
        }
      end
    end

    def can_create_feedback?(project, feedback_type)
      feedback = Vulnerabilities::Feedback.new(project: project, feedback_type: feedback_type)
      can?(current_user, :create_vulnerability_feedback, feedback)
    end

    def create_vulnerability_feedback_issue_path(project)
      if can_create_feedback?(project, :issue)
        project_vulnerability_feedback_index_path(project)
      end
    end

    def create_vulnerability_feedback_merge_request_path(project)
      if can_create_feedback?(project, :merge_request)
        project_vulnerability_feedback_index_path(project)
      end
    end

    def create_vulnerability_feedback_dismissal_path(project)
      if can_create_feedback?(project, :dismissal)
        project_vulnerability_feedback_index_path(project)
      end
    end

    def any_project_nav_tab?(tabs)
      tabs.any? { |tab| project_nav_tab?(tab) }
    end

    def show_discover_project_security?(project)
      security_feature_available_at = DateTime.new(2019, 11, 1)

      !!current_user &&
        ::Gitlab.com? &&
        current_user.created_at > security_feature_available_at &&
        !project.feature_available?(:security_dashboard) &&
        can?(current_user, :admin_namespace, project.root_ancestor) &&
        current_user.ab_feature_enabled?(:discover_security)
    end

    def settings_operations_available?
      return true if super

      @project.feature_available?(:tracing, current_user) && can?(current_user, :read_environment, @project)
    end

    override :can_import_members?
    def can_import_members?
      super && !membership_locked?
    end

    def show_compliance_framework_badge?(project)
      project&.compliance_framework_setting&.present?
    end

    def scheduled_for_deletion?(project)
      project.marked_for_deletion_at.present?
    end

    private

    def get_project_security_nav_tabs(project, current_user)
      nav_tabs = []

      if can?(current_user, :read_project_security_dashboard, project)
        nav_tabs << :security
        nav_tabs << :security_configuration
      end

      if can?(current_user, :read_on_demand_scans, @project)
        nav_tabs << :on_demand_scans
      end

      if can?(current_user, :read_dependencies, project)
        nav_tabs << :dependencies
      end

      if can?(current_user, :read_licenses, project)
        nav_tabs << :licenses
      end

      if can?(current_user, :read_threat_monitoring, project)
        nav_tabs << :threat_monitoring
      end

      nav_tabs
    end
  end
end
