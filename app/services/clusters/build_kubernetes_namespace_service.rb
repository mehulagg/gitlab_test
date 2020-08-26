# frozen_string_literal: true

module Clusters
  class BuildKubernetesNamespaceService
    attr_reader :cluster, :environment, :namespace

    def initialize(cluster, environment:, namespace:)
      @cluster = cluster
      @environment = environment
      @namespace = namespace
    end

    def execute
      cluster.kubernetes_namespaces.build(attributes)
    end

    private

    def attributes
      attributes = {
        project: environment.project,
        namespace: namespace,
        service_account_name: "#{namespace}-service-account"
      }

      attributes[:cluster_project] = cluster.cluster_project if cluster.project_type?
      attributes[:environment] = environment if cluster.namespace_per_environment?

      attributes
    end
  end
end
