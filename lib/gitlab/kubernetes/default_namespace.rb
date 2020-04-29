# frozen_string_literal: true

module Gitlab
  module Kubernetes
    class DefaultNamespace
      attr_reader :cluster, :project

      delegate :platform_kubernetes, to: :cluster

      ##
      # Ideally we would just use an environment record here instead of
      # passing a project and name/slug separately, but we need to be able
      # to look up namespaces before the environment has been persisted.
      def initialize(cluster, project:)
        @cluster = cluster
        @project = project
      end

      def from_environment_name(name)
        from_environment_slug(generate_slug(name))
      end

      def from_environment_slug(slug)
        default_platform_namespace(slug) || default_project_namespace(slug)
      end

      private

      def default_platform_namespace(slug)
        return unless platform_kubernetes&.namespace.present?

        if cluster.managed? && cluster.namespace_per_environment?
          "#{platform_kubernetes.namespace}-#{slug}"
        else
          platform_kubernetes.namespace
        end
      end

      def default_project_namespace(environment_slug)
        namespace_suffix = cluster.namespace_per_environment? ? "-#{environment_slug}" : ''
        project_id_str = project.id.to_s
        project_path_slug_budget = 63 - project_id_str.length - namespace_suffix.length - 1
        project_path_slug = Gitlab::NamespaceSanitizer.sanitize(project.path.downcase).first(project_path_slug_budget)
        namespace_base = "#{project_path_slug}-#{project_id_str}#{namespace_suffix}"
        Gitlab::NamespaceSanitizer.sanitize(namespace_base)
      end

      ##
      # Environment slug can be predicted given an environment
      # name, so even if the environment isn't persisted yet we
      # still know what to look for.
      def generate_slug(name)
        Gitlab::Slug::Environment.new(name).generate
      end
    end
  end
end
