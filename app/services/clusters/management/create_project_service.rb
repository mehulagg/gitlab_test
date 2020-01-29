# frozen_string_literal: true

module Clusters
  module Management
    class CreateProjectService
      CreateError = Class.new(StandardError)

      attr_reader :cluster, :current_user

      def initialize(cluster, current_user:)
        @cluster = cluster
        @current_user = current_user
      end

      def execute
        return unless management_project_required?

        ActiveRecord::Base.transaction do
          project = create_management_project!
          update_cluster!(project)

          # Group and instance type clusters don't need members
          # added explicitly because they are already maintainers
          # of the group, so they have maintainer access to
          # the management project by default.
          if cluster.project_type?
            add_project_members!(project)
          end
        end
      end

      private

      def management_project_required?
        Feature.enabled?(:auto_create_cluster_management_project) && cluster.management_project.nil?
      end

      def project_params
        {
          name: project_name,
          description: project_description,
          namespace_id: namespace.id,
          visibility_level: Gitlab::VisibilityLevel::PRIVATE
        }
      end

      def project_name
        _("%{cluster_name} Cluster Management") % { cluster_name: cluster.name }
      end

      def project_description
        _("This project is automatically generated and will be used to manage your Kubernetes cluster. [More information](%{docs_path})") % { docs_path: docs_path }
      end

      def docs_path
        Rails.application.routes.url_helpers.help_page_path('user/clusters/management_project')
      end

      def create_management_project!
        ::Projects::CreateService.new(current_user, project_params).execute.tap do |project|
          errors = project.errors.full_messages

          if errors.any?
            raise CreateError.new("Failed to create project: #{errors}")
          end
        end
      end

      def update_cluster!(project)
        unless cluster.update(management_project: project)
          raise CreateError.new("Failed to update cluster: #{cluster.errors.full_messages}")
        end
      end

      def add_project_members!(project)
        members = project.add_users(project_maintainers, Gitlab::Access::MAINTAINER)
        errors = members.flat_map { |member| member.errors.full_messages }

        if errors.any?
          raise CreateError.new("Failed to add members to project: #{errors}")
        end
      end

      def namespace
        case cluster.cluster_type
        when 'project_type'
          cluster.project.namespace
        when 'group_type'
          cluster.group
        when 'instance_type'
          instance_administrators_group || current_user.namespace
        else
          raise NotImplementedError
        end
      end

      def instance_administrators_group
        Gitlab::CurrentSettings.instance_administrators_group
      end

      def project_maintainers
        all_maintainers = cluster.project.members
          .active
          .maintainers
          .map(&:user)

        # Current user already owns the project
        all_maintainers - [current_user]
      end
    end
  end
end
