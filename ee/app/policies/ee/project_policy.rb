# frozen_string_literal: true

module EE
  module ProjectPolicy
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override

    prepended do
      with_scope :subject
      condition(:repository_mirrors_enabled) { @subject.feature_available?(:repository_mirrors) }

      with_scope :subject
      condition(:deploy_board_disabled) { !@subject.feature_available?(:deploy_board) }

      with_scope :subject
      condition(:iterations_available) { @subject.feature_available?(:iterations) }

      with_scope :subject
      condition(:requirements_available) { @subject.feature_available?(:requirements) }

      condition(:compliance_framework_available) { @subject.feature_available?(:compliance_framework, @user) }

      with_scope :global
      condition(:is_development) { Rails.env.development? }

      with_scope :global
      condition(:reject_unsigned_commits_disabled_globally) do
        !PushRule.global&.reject_unsigned_commits
      end

      with_scope :global
      condition(:commit_committer_check_disabled_globally) do
        !PushRule.global&.commit_committer_check
      end

      with_scope :subject
      condition(:regulated_merge_request_approval_settings) do
        License.feature_available?(:admin_merge_request_approvers_rules) &&
          @subject.has_regulated_settings?
      end

      condition(:project_merge_request_analytics_available) do
        @subject.feature_available?(:project_merge_request_analytics)
      end

      with_scope :subject
      condition(:group_push_rules_enabled) do
        @subject.group && @subject.group.feature_available?(:push_rules)
      end

      with_scope :subject
      condition(:group_push_rule_present) do
        group_push_rules_enabled? && subject.group.push_rule
      end

      with_scope :subject
      condition(:reject_unsigned_commits_disabled_by_group) do
        if group_push_rule_present?
          !subject.group.push_rule.reject_unsigned_commits
        else
          true
        end
      end

      condition(:can_change_reject_unsigned_commits) do
        admin? ||
          (can?(:maintainer_access) &&
            reject_unsigned_commits_disabled_globally? &&
            reject_unsigned_commits_disabled_by_group?)
      end

      condition(:commit_committer_check_disabled_by_group) do
        if group_push_rule_present?
          !subject.group.push_rule.commit_committer_check
        else
          true
        end
      end

      with_scope :subject
      condition(:commit_committer_check_available) do
        @subject.feature_available?(:commit_committer_check)
      end

      condition(:can_change_commit_commiter_check) do
        admin? ||
          (can?(:maintainer_access) &&
            commit_committer_check_disabled_globally? &&
            commit_committer_check_disabled_by_group?)
      end

      with_scope :subject
      condition(:reject_unsigned_commits_available) do
        @subject.feature_available?(:reject_unsigned_commits)
      end

      with_scope :subject
      condition(:security_dashboard_enabled) do
        @subject.feature_available?(:security_dashboard)
      end

      with_scope :subject
      condition(:on_demand_scans_enabled) do
        ::Feature.enabled?(:security_on_demand_scans_feature_flag, project, default_enabled: true) &&
        @subject.feature_available?(:security_on_demand_scans)
      end

      with_scope :subject
      condition(:license_scanning_enabled) do
        @subject.feature_available?(:license_scanning)
      end

      with_scope :subject
      condition(:dependency_scanning_enabled) do
        @subject.feature_available?(:dependency_scanning)
      end

      with_scope :subject
      condition(:threat_monitoring_enabled) do
        @subject.feature_available?(:threat_monitoring)
      end

      with_scope :subject
      condition(:code_review_analytics_enabled) do
        @subject.feature_available?(:code_review_analytics, @user)
      end

      condition(:status_page_available) do
        @subject.feature_available?(:status_page, @user)
      end

      condition(:group_timelogs_available) do
        @subject.feature_available?(:group_timelogs)
      end

      condition(:over_storage_limit, scope: :subject) do
        @subject.root_namespace.over_storage_limit?
      end

      with_scope :subject
      condition(:feature_flags_related_issues_disabled) do
        !@subject.feature_available?(:feature_flags_related_issues)
      end

      rule { visual_review_bot }.policy do
        prevent :read_note
        enable :create_note
      end

      rule { license_block }.policy do
        prevent :create_issue
        prevent :create_merge_request_in
        prevent :create_merge_request_from
        prevent :push_code
      end

      rule { feature_flags_related_issues_disabled | repository_disabled }.policy do
        prevent :admin_feature_flags_issue_links
      end

      rule { ~group_timelogs_available }.prevent :read_group_timelogs

      rule { can?(:guest_access) & iterations_available }.enable :read_iteration

      rule { can?(:reporter_access) }.policy do
        enable :admin_board
        enable :read_deploy_board
        enable :admin_epic_issue
        enable :read_group_timelogs
      end

      rule { can?(:developer_access) }.policy do
        enable :admin_board
        enable :read_vulnerability_feedback
        enable :create_vulnerability_feedback
        enable :destroy_vulnerability_feedback
        enable :update_vulnerability_feedback
        enable :read_ci_minutes_quota
        enable :admin_feature_flags_issue_links
      end

      rule { can?(:developer_access) & iterations_available }.policy do
        enable :create_iteration
        enable :admin_iteration
      end

      rule { can?(:read_project) & iterations_available }.enable :read_iteration

      rule { security_dashboard_enabled & can?(:developer_access) }.policy do
        enable :read_vulnerability
        enable :read_vulnerability_scanner
      end

      rule { on_demand_scans_enabled & can?(:developer_access) }.policy do
        enable :read_on_demand_scans
        enable :create_on_demand_dast_scan
      end

      rule { can?(:read_merge_request) & can?(:read_pipeline) }.enable :read_merge_train

      rule { can?(:read_vulnerability) }.policy do
        enable :read_project_security_dashboard
        enable :create_vulnerability
        enable :create_vulnerability_export
        enable :admin_vulnerability
        enable :admin_vulnerability_issue_link
      end

      rule { issues_disabled & merge_requests_disabled }.policy do
        prevent(*create_read_update_admin_destroy(:iteration))
      end

      rule { threat_monitoring_enabled & (auditor | can?(:developer_access)) }.enable :read_threat_monitoring

      rule { dependency_scanning_enabled & can?(:download_code) }.enable :read_dependencies

      rule { license_scanning_enabled & can?(:download_code) }.enable :read_licenses

      rule { can?(:read_licenses) }.enable :read_software_license_policy

      rule { repository_mirrors_enabled & ((mirror_available & can?(:admin_project)) | admin) }.enable :admin_mirror

      rule { deploy_board_disabled & ~is_development }.prevent :read_deploy_board

      rule { can?(:maintainer_access) }.policy do
        enable :push_code_to_protected_branches
        enable :admin_path_locks
        enable :update_approvers
        enable :modify_approvers_rules
        enable :modify_auto_fix_setting
        enable :modify_merge_request_author_setting
        enable :modify_merge_request_committer_setting
      end

      rule { license_scanning_enabled & can?(:maintainer_access) }.enable :admin_software_license_policy

      rule { auditor }.policy do
        enable :public_user_access
        prevent :request_access

        enable :read_build
        enable :read_environment
        enable :read_deployment
        enable :read_pages
      end

      rule { auditor & security_dashboard_enabled }.policy do
        enable :read_vulnerability
        enable :read_vulnerability_scanner
      end

      rule { auditor & ~developer }.policy do
        prevent :create_vulnerability
        prevent :admin_vulnerability
        prevent :admin_vulnerability_issue_link
      end

      rule { auditor & ~guest }.policy do
        prevent :create_project
        prevent :create_issue
        prevent :create_note
        prevent :upload_file
      end

      rule { ~can?(:push_code) }.prevent :push_code_to_protected_branches

      rule { can_change_reject_unsigned_commits }.enable :change_reject_unsigned_commits

      rule { reject_unsigned_commits_available }.enable :read_reject_unsigned_commits

      rule { ~reject_unsigned_commits_available }.prevent :change_reject_unsigned_commits

      rule { can_change_commit_commiter_check }.enable :change_commit_committer_check

      rule { commit_committer_check_available }.enable :read_commit_committer_check

      rule { ~commit_committer_check_available }.prevent :change_commit_committer_check

      rule { owner | reporter }.enable :build_read_project

      rule { ~admin & owner & owner_cannot_destroy_project }.prevent :remove_project

      condition(:needs_new_sso_session) do
        ::Gitlab::Auth::GroupSaml::SsoEnforcer.group_access_restricted?(subject.group)
      end

      condition(:ip_enforcement_prevents_access) do
        !::Gitlab::IpRestriction::Enforcer.new(subject.group).allows_current_ip? if subject.group
      end

      condition(:owner_cannot_destroy_project) do
        ::Gitlab::CurrentSettings.current_application_settings
          .default_project_deletion_protection
      end

      rule { needs_new_sso_session & ~admin }.policy do
        prevent :guest_access
        prevent :reporter_access
        prevent :developer_access
        prevent :maintainer_access
        prevent :owner_access
      end

      rule { ip_enforcement_prevents_access & ~admin }.policy do
        prevent :read_project
      end

      rule { regulated_merge_request_approval_settings }.policy do
        prevent :modify_approvers_rules
        prevent :modify_merge_request_author_setting
        prevent :modify_merge_request_committer_setting
      end

      rule { can?(:read_merge_request) & code_review_analytics_enabled }.enable :read_code_review_analytics

      rule { reporter & project_merge_request_analytics_available }
        .enable :read_project_merge_request_analytics

      rule { can?(:read_project) & requirements_available }.enable :read_requirement

      rule { requirements_available & reporter }.policy do
        enable :create_requirement
        enable :create_requirement_test_report
        enable :admin_requirement
        enable :update_requirement
      end

      rule { requirements_available & owner }.enable :destroy_requirement

      rule { compliance_framework_available & can?(:admin_project) }.enable :admin_compliance_framework

      rule { status_page_available & can?(:owner_access) }.enable :mark_issue_for_publication
      rule { status_page_available & can?(:developer_access) }.enable :publish_status_page

      rule { public_project }.enable :view_embedded_analytics_report

      rule { over_storage_limit }.policy do
        prevent(*readonly_abilities)

        readonly_features.each do |feature|
          prevent(*create_update_admin(feature))
        end
      end
    end

    override :lookup_access_level!
    def lookup_access_level!
      return ::Gitlab::Access::NO_ACCESS if needs_new_sso_session?
      return ::Gitlab::Access::NO_ACCESS if visual_review_bot?

      super
    end
  end
end
