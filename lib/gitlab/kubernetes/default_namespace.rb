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
        base = default_platform_namespace_base(slug) || default_project_namespace_base(slug)
        reduce_to_63_characters(base)
      end

      private

      def reduce_to_63_characters(namespace_base)
        return namespace_base if namespace_base.length <= 63

        suffix = Digest::SHA2.hexdigest(namespace_base).to_i(16).to_s(36)
        prefix_length = 63 - suffix.length
        prefix = namespace_base[0...prefix_length]
        prefix + suffix
      end

      def default_platform_namespace_base(slug)
        return unless platform_kubernetes&.namespace.present?

        if cluster.managed? && cluster.namespace_per_environment?
          "#{platform_kubernetes.namespace}-#{slug}"
        else
          platform_kubernetes.namespace
        end
      end

      def default_project_namespace_base(slug)
        namespace_slug = "#{project.path}-#{project.id}".downcase

        if cluster.namespace_per_environment?
          namespace_slug += "-#{slug}"
        end

        Gitlab::NamespaceSanitizer.sanitize(namespace_slug)
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
