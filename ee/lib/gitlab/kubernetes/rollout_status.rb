# frozen_string_literal: true

module Gitlab
  module Kubernetes
    # Calculates the rollout status for a set of kubernetes deployments.
    #
    # A GitLab environment may be composed of several Kubernetes deployments and
    # other resources. The rollout status sums the Kubernetes deployments
    # together.
    class RolloutStatus
      attr_reader :deployments, :instances, :completion, :status

      def complete?
        completion == 100
      end

      def loading?
        @status == :loading
      end

      def not_found?
        @status == :not_found
      end

      def has_legacy_app_label?
        legacy_deployments.present?
      end

      def found?
        @status == :found
      end

      def self.from_deployments(*deployments, pods: {}, legacy_deployments: [])
        return new([], status: :not_found, legacy_deployments: legacy_deployments) if deployments.empty?

        deployments = deployments.map { |deploy| ::Gitlab::Kubernetes::Deployment.new(deploy, pods: pods) }
        deployments.sort_by!(&:order)

        pods = pods.map { |pod| ::Gitlab::Kubernetes::Pod.new(pod) }

        rollout_status_pods = create_rollout_status_pods(deployments, pods)

        new(deployments, pods: rollout_status_pods, legacy_deployments: legacy_deployments)
      end

      def self.loading
        new([], status: :loading)
      end

      def initialize(deployments, pods: [], status: :found, legacy_deployments: [])
        @status       = status
        @deployments  = deployments
        @instances    = pods
        @legacy_deployments = legacy_deployments

        @completion =
          if @instances.empty?
            100
          else
            # We downcase the pod status in Gitlab::Kubernetes::Deployment#deployment_instance
            finished = @instances.count { |instance| instance[:status] == ::Gitlab::Kubernetes::Pod::RUNNING.downcase }

            (finished / @instances.count.to_f * 100).to_i
          end
      end

      private

      attr_reader :legacy_deployments

      def self.create_rollout_status_pods(deployments, pods)
        deployment_tracks = deployments.map(&:track)
        filtered_pods = pods.select { |p| deployment_tracks.include?(p.track) }

        wanted_instances = deployments.map { |d| { d.track => d.wanted_instances } }.reduce do |memo, h|
          memo.merge(h) { |_key, val1, val2| val1 + val2 }
        end
        present_instances = filtered_pods.map { |p| { p.track => 1 } }.reduce({}) { |memo, h| memo.merge(h) { |_key, val1, val2| val1 + val2 } }
        pending_instances = wanted_instances.merge(present_instances) { |_key, wanted, present| [0, wanted - present].max }

        pending_pods = pending_instances.flat_map do |track, num|
          Array.new(num, pending_pod_for(track))
        end
        total_pods = filtered_pods + pending_pods

        total_pods.sort_by(&:order).map(&:to_hash)
      end

      def self.pending_pod_for(track)
        ::Gitlab::Kubernetes::Pod.new({
          'status' => { 'phase' => 'Pending' },
          'metadata' => {
            'name' => 'Not provided',
            'labels' => {
              'track' => track
            }
          }

        })
      end
    end
  end
end
