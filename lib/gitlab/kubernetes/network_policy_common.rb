# frozen_string_literal: true

module Gitlab
  module Kubernetes
    class NetworkPolicyCommon
      DISABLED_BY_LABEL = :'network-policy.gitlab.com/disabled_by'

      def initialize(name, namespace, resource_version, selector, labels=nil, creation_timestamp= nil, ingress= nil, egress= nil)
        @name = name
        @namespace = namespace
        @resource_version = resource_version
        @labels = labels
        @creation_timestamp = creation_timestamp
        @selector = selector
        @ingress = ingress
        @egress = egress
      end

      def generate
        ::Kubeclient::Resource.new.tap do |resource|
          resource.kind = kind
          resource.apiVersion = self.class.api_version if self.class.respond_to?(:api_version)
          resource.metadata = metadata
          resource.spec = spec
        end
      end

      def as_json(opts = nil)
        {
          name: name,
          namespace: namespace,
          creation_timestamp: creation_timestamp,
          manifest: manifest,
          is_autodevops: autodevops?,
          is_enabled: enabled?,
          is_standard: standard?,
          resource_version: resource_version
        }
      end

      def autodevops?
        return false unless labels

        !labels[:chart].nil? && labels[:chart].start_with?('auto-deploy-app-')
      end

      # podSelector selects pods that should be targeted by this
      # policy. We can narrow selection by requiring this policy to
      # match our custom labels. Since DISABLED_BY label will not be
      # on any pod a policy will be effectively disabled.
      def enabled?
        return true unless @selector&.key?(:matchLabels)

        !@selector[:matchLabels]&.key?(DISABLED_BY_LABEL)
      end

      def enable
        return if enabled?

        @selector[:matchLabels].delete(DISABLED_BY_LABEL)
      end

      def disable
        @selector ||= {}
        @selector[:matchLabels] ||= {}
        @selector[:matchLabels].merge!(DISABLED_BY_LABEL => 'gitlab')
      end

      def standard?
        self.is_a?(NetworkPolicy)
      end

      private

      attr_reader :name, :namespace, :labels, :creation_timestamp, :resource_version, :selector, :ingress, :egress

      def metadata
        meta = { name: name, namespace: namespace, resourceVersion: resource_version }.compact
        meta[:labels] = labels if labels
        meta
      end

      def spec
        raise NotImplementedError
      end

      def kind
        self.class.name.split("::").last
      end

      def manifest
        YAML.dump({ metadata: metadata, spec: spec }.deep_stringify_keys)
      end
    end
  end
end