# frozen_string_literal: true

module Clusters
  class DestroyService
    attr_reader :current_user, :params

    def initialize(user = nil, params = {})
      @current_user, @params = user, params.dup
      @response = {}
    end

    def execute(cluster)
      params[:cleanup] == 'true' ? start_cleanup!(cluster) : destroy_cluster(cluster)

      @response
    end

    private

    def start_cleanup!(cluster)
      cluster.start_cleanup!
      @response[:message] = 'Kubernetes cluster integration and resources are being removed.'
    end

    def destroy_cluster(cluster)
      cluster.destroy!
      @response[:message] = 'Kubernetes cluster integration was successfully removed.'
    end
  end
end
