# frozen_string_literal: true

module Gitlab
  module Ci
    module Build
      module Prerequisite
        class KubernetesNamespace < Base
          def unmet?
            cluster.present? &&
              cluster.managed? &&
              missing_namespace?
          end

          def complete!
            return unless unmet?

            create_namespace
          end

          private

          def missing_namespace?
            existing_kubernetes_namespace_record.nil? || existing_kubernetes_namespace_record.service_account_token.blank?
          end

          def cluster
            build.deployment&.cluster
          end

          def environment
            build.deployment.environment
          end

          def existing_kubernetes_namespace_record
            strong_memoize(:existing_kubernetes_namespace_record) do
              cluster.kubernetes_namespace_by_name(requested_kubernetes_namespace_name)
            end
          end

          def requested_kubernetes_namespace_name
            build.deployment.kubernetes_namespace
          end

          def create_namespace
            ::Clusters::Kubernetes::CreateOrUpdateNamespaceService.new(
              cluster: cluster,
              kubernetes_namespace: existing_kubernetes_namespace_record || build_kubernetes_namespace_record
            ).execute
          end

          def build_kubernetes_namespace_record
            ::Clusters::BuildKubernetesNamespaceService.new(
              cluster,
              environment: environment,
              namespace: requested_kubernetes_namespace_name
            ).execute
          end
        end
      end
    end
  end
end
