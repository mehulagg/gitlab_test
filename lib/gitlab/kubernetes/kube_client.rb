# frozen_string_literal: true

require 'uri'

module Gitlab
  module Kubernetes
    # Wrapper around Kubeclient::Client to dispatch
    # the right message to the client that can respond to the message.
    # We must have a kubeclient for each ApiGroup as there is no
    # other way to use the Kubeclient gem.
    #
    # See https://github.com/abonas/kubeclient/issues/348.
    class KubeClient
      include Gitlab::Utils::StrongMemoize

      SUPPORTED_API_GROUPS = {
        core: { group: 'api', version: 'v1' },
        rbac: { group: 'apis/rbac.authorization.k8s.io', version: 'v1' },
        apps: { group: 'apis/apps', version: 'v1' },
        extensions: { group: 'apis/extensions', version: 'v1beta1' },
        istio: { group: 'apis/networking.istio.io', version: 'v1alpha3' },
        knative: { group: 'apis/serving.knative.dev', version: 'v1alpha1' },
        networking: { group: 'apis/networking.k8s.io', version: 'v1' }
      }.freeze

      SUPPORTED_API_GROUPS.each do |name, params|
        client_method_name = "#{name}_client".to_sym

        define_method(client_method_name) do
          strong_memoize(client_method_name) do
            build_kubeclient(params[:group], params[:version])
          end
        end
      end

      # Core API methods delegates to the core api group client
      delegate :get_pods,
        :get_secrets,
        :get_config_map,
        :get_namespace,
        :get_pod,
        :get_secret,
        :get_service,
        :get_service_account,
        :delete_namespace,
        :delete_pod,
        :delete_service_account,
        :create_config_map,
        :create_namespace,
        :create_pod,
        :create_secret,
        :create_service_account,
        :update_config_map,
        :update_secret,
        :update_service_account,
        to: :core_client

      # RBAC methods delegates to the apis/rbac.authorization.k8s.io api
      # group client
      delegate :update_cluster_role_binding,
        to: :rbac_client

      # RBAC methods delegates to the apis/rbac.authorization.k8s.io api
      # group client
      delegate :create_role,
      :get_role,
      :update_role,
      to: :rbac_client

      # RBAC methods delegates to the apis/rbac.authorization.k8s.io api
      # group client
      delegate :update_role_binding,
        to: :rbac_client

      # non-entity methods that can only work with the core client
      # as it uses the pods/log resource
      delegate :get_pod_log,
        :watch_pod_log,
        to: :core_client

      # Gateway methods delegate to the apis/networking.istio.io api
      # group client
      delegate :create_gateway,
        :get_gateway,
        :update_gateway,
        to: :istio_client

      # NetworkPolicy methods delegate to the apis/networking.k8s.io api
      # group client
      delegate :create_network_policy,
        :get_network_policies,
        :update_network_policy,
        :delete_network_policy,
        to: :networking_client

      attr_reader :api_prefix, :kubeclient_options

      DEFAULT_KUBECLIENT_OPTIONS = {
        timeouts: {
          open: 10,
          read: 30
        }
      }.freeze

      # We disable redirects through 'http_max_redirects: 0',
      # so that KubeClient does not follow redirects and
      # expose internal services.
      def initialize(api_prefix, **kubeclient_options)
        @api_prefix = api_prefix
        @kubeclient_options = DEFAULT_KUBECLIENT_OPTIONS
          .deep_merge(kubeclient_options)
          .merge(http_max_redirects: 0)

        validate_url!
      end

      # Deployments resource is currently on the apis/extensions api group
      # until Kubernetes 1.15. Kubernetest 1.16+ has deployments resources in
      # the apis/apps api group.
      #
      # As we still support Kubernetes 1.12+, we will need to support both.
      def get_deployments(**args)
        extensions_client.discover unless extensions_client.discovered

        if extensions_client.respond_to?(:get_deployments)
          extensions_client.get_deployments(**args)
        else
          apps_client.get_deployments(**args)
        end
      end

      def create_or_update_cluster_role_binding(resource)
        update_cluster_role_binding(resource)
      end

      def create_or_update_role_binding(resource)
        update_role_binding(resource)
      end

      def create_or_update_service_account(resource)
        if service_account_exists?(resource)
          update_service_account(resource)
        else
          create_service_account(resource)
        end
      end

      def create_or_update_secret(resource)
        if secret_exists?(resource)
          update_secret(resource)
        else
          create_secret(resource)
        end
      end

      private

      def validate_url!
        return if Gitlab::CurrentSettings.allow_local_requests_from_web_hooks_and_services?

        Gitlab::UrlBlocker.validate!(api_prefix, allow_local_network: false)
      end

      def service_account_exists?(resource)
        get_service_account(resource.metadata.name, resource.metadata.namespace)
      rescue ::Kubeclient::ResourceNotFoundError
        false
      end

      def secret_exists?(resource)
        get_secret(resource.metadata.name, resource.metadata.namespace)
      rescue ::Kubeclient::ResourceNotFoundError
        false
      end

      def build_kubeclient(api_group, api_version)
        ::Kubeclient::Client.new(
          join_api_url(api_prefix, api_group),
          api_version,
          **kubeclient_options
        )
      end

      def join_api_url(api_prefix, api_path)
        url = URI.parse(api_prefix)
        prefix = url.path.sub(%r{/+\z}, '')

        url.path = [prefix, api_path].join("/")

        url.to_s
      end
    end
  end
end
