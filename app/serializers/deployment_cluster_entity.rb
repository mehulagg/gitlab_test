# frozen_string_literal: true

class DeploymentClusterEntity < Grape::Entity
  include RequestAwareEntity

  expose :name do |deployment_cluster|
    deployment_cluster.cluster.name
  end

  expose :path, if: -> (deployment_cluster) { can?(request.current_user, :read_cluster, deployment_cluster.cluster) } do |deployment_cluster|
    deployment_cluster.cluster.present(current_user: request.current_user).show_path
  end

  expose :kubernetes_namespace, if: -> (deployment_cluster) { can?(request.current_user, :read_cluster, deployment_cluster.cluster) } do |deployment_cluster|
    deployment_cluster.kubernetes_namespace
  end
end
