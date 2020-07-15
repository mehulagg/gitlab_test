# frozen_string_literal: true

module Clusters
  module Applications
    class ActivateServiceWorker # rubocop:disable Scalability/IdempotentWorker
      include ApplicationWorker
      include ClusterQueue

      loggable_arguments 1

      def perform(cluster_id, service_name)
        cluster = Clusters::Cluster.find_by_id(cluster_id)
        prometheus_application = cluster&.application_prometheus
        return unless cluster

        cluster.all_projects.find_each do |project|
          service = project.find_or_initialize_service(service_name)
          create_prometheus_configuration(service, prometheus_application)
          service.update!(active: true)
        end
      end

      def create_prometheus_configuration(service, prometheus_application)
        return unless service.is_a?(PrometheusService) && prometheus_application
        prometheus_application.prometheus_api_config.create(api_url: prometheus_application.proxy_url, headers: prometheus_application.proxy_headers, project_services_prometheus_service: service)
      end
    end
  end
end
