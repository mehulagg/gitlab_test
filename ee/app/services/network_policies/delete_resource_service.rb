# frozen_string_literal: true

module NetworkPolicies
  class DeleteResourceService
    include NetworkPolicies::Responses

    def initialize(resource_name:, environment:, is_standard:)
      @resource_name = resource_name
      @platform = environment.deployment_platform
      @kubernetes_namespace = environment.deployment_namespace
      @is_standard = is_standard
    end

    def execute
      return no_platform_response unless @platform

      if @is_standard
        @platform.kubeclient.delete_network_policy(@resource_name, @kubernetes_namespace)
      else
        @platform.kubeclient.delete_cilium_network_policy(@resource_name, @kubernetes_namespace)
      end

      ServiceResponse.success
    rescue Kubeclient::HttpError => e
      kubernetes_error_response(e)
    end
  end
end
