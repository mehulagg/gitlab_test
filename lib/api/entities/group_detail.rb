# frozen_string_literal: true

module API
  module Entities
    class GroupDetail < Group
      expose :runners_token, if: lambda { |group, options| options[:user_can_admin_group] }

      expose :projects, unless: lambda { |_, _| hide_projects_in_groups_api? },
        using: Entities::Project do |group, options|
        projects = GroupProjectsFinder.new(
          group: group,
          current_user: options[:current_user],
          options: { only_owned: true, limit: projects_limit }
        ).execute

        Entities::Project.prepare_relation(projects)
      end

      expose :shared_projects, unless: lambda { |_, _| hide_projects_in_groups_api? },
        using: Entities::Project do |group, options|
        projects = GroupProjectsFinder.new(
          group: group,
          current_user: options[:current_user],
          options: { only_shared: true, limit: projects_limit }
        ).execute

        Entities::Project.prepare_relation(projects)
      end

      def projects_limit
        if ::Feature.enabled?(:limit_projects_in_groups_api, default_enabled: true)
          GroupProjectsFinder::DEFAULT_PROJECTS_LIMIT
        else
          nil
        end
      end

      # TODO: Remove in 13.1: https://gitlab.com/gitlab-org/gitlab/-/issues/216440
      def hide_projects_in_groups_api?
        ::Feature.enabled?(:hide_projects_in_groups_api, default_enabled: true)
      end
    end
  end
end

API::Entities::GroupDetail.prepend_if_ee('EE::API::Entities::GroupDetail')
