module EE
  module Projects
    module CreateService
      extend ::Gitlab::Utils::Override
      include ::Gitlab::Utils::StrongMemoize

      override :execute
      def execute
        limit = params.delete(:repository_size_limit)
        mirror_trigger_builds = params.delete(:mirror_trigger_builds)

        project = super do |project|
          # Repository size limit comes as MB from the view
          project.repository_size_limit = ::Gitlab::Utils.try_megabytes_to_bytes(limit) if limit

          if mirror && project.feature_available?(:repository_mirrors)
            project.mirror = mirror unless mirror.nil?
            project.mirror_trigger_builds = mirror_trigger_builds unless mirror_trigger_builds.nil?
            project.mirror_user_id = mirror_user_id
          end
        end

        if project&.persisted?
          log_geo_event(project)
          log_audit_event(project)
        end

        project
      end

      private

      def ci_cd_project?
        project.ci_cd_only?
      end

      def mirror
        strong_memoize(:mirror) do
          ci_cd_project? ? true : params.delete(:mirror)
        end
      end

      def mirror_user_id
        strong_memoize(:mirror_user_id) do
          ci_cd_project? ? current_user.id : params.delete(:mirror_user_id)
        end
      end

      def log_geo_event(project)
        ::Geo::RepositoryCreatedEventStore.new(project).create
      end

      override :after_create_actions
      def after_create_actions
        super

        create_predefined_push_rule unless ci_cd_project?
        setup_ci_cd_project         if ci_cd_project?

        project.group&.refresh_members_authorized_projects
      end

      def create_predefined_push_rule
        return unless project.feature_available?(:push_rules)

        predefined_push_rule = PushRule.find_by(is_sample: true)

        if predefined_push_rule
          push_rule = predefined_push_rule.dup.tap { |gh| gh.is_sample = false }
          project.push_rule = push_rule
        end
      end

      def setup_ci_cd_project
        project.update_attributes!(
          container_registry_enabled: false,
          mirror: true
        )

        project.project_feature.update_attributes!(
          issues_access_level:         ProjectFeature::DISABLED,
          merge_requests_access_level: ProjectFeature::DISABLED,
          wiki_access_level:           ProjectFeature::DISABLED,
          snippets_access_level:       ProjectFeature::DISABLED
        )
      end

      def log_audit_event(project)
        ::AuditEventService.new(
          current_user,
          project,
          action: :create
        ).for_project.security_event
      end
    end
  end
end
