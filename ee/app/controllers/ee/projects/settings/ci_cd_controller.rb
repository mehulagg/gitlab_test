# frozen_string_literal: true
module EE
  module Projects
    module Settings
      module CiCdController
        include ::API::Helpers::RelatedResourcesHelpers
        extend ::Gitlab::Utils::Override
        extend ActiveSupport::Concern

        prepended do
          before_action :log_access_ci_cd_settings, only: :show
          before_action :assign_variables_to_gon, only: :show
          before_action :define_protected_env_variables, only: :show
        end

        # rubocop:disable Gitlab/ModuleWithInstanceVariables
        override :show
        def show
          if project.feature_available?(:license_management)
            @license_management_url = expose_url(api_v4_projects_managed_licenses_path(id: @project.id))
          end

          super
        end

        def log_audit_event(message:)
          AuditEvents::CustomAuditEventService.new(
            current_user,
            project,
            request.remote_ip,
            message
          ).for_project.security_event
        end

        def log_access_ci_cd_settings
          log_audit_event(message: 'Accessed CI/CD settings')
        end

        private

        def define_protected_env_variables
          @protected_environments = @project.protected_environments.with_environment_id.sorted_by_name
          @protected_environment = ProtectedEnvironment.new(project: @project)
        end

        def assign_variables_to_gon
          gon.push(current_project_id: project.id)
          gon.push(deploy_access_levels: environment_dropdown.roles_hash)
          gon.push(search_unprotected_environments_url: search_project_protected_environments_path(@project))
        end

        def environment_dropdown
          @environment_dropdown ||= ProtectedEnvironments::EnvironmentDropdownService
        end
      end
    end
  end
end
