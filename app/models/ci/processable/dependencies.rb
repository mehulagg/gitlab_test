# frozen_string_literal: true

module Ci
  class Processable
    class Dependencies
      include Gitlab::Utils::StrongMemoize

      attr_reader :processable

      def initialize(processable)
        @processable = processable
      end

      def all
        (local + cross_pipeline).uniq
      end

      # Dependencies local to the given pipeline
      def local
        return [] if no_dependencies_specified?

        depended_jobs = jobs_from_previous_stages
        depended_jobs = jobs_from_needs(depended_jobs)
        depended_jobs = jobs_from_dependencies(depended_jobs)
        depended_jobs
      end

      # Dependencies that are defined in other pipelines
      def cross_pipeline
        []
      end

      def invalid_local
        local.reject(&:valid_dependency?)
      end

      def valid_local?
        return true if Feature.enabled?('ci_disable_validates_dependencies')

        local.all?(&:valid_dependency?)
      end

      private

      def project
        strong_memoize(:project) do
          processable.project
        end
      end

      def no_dependencies_specified?
        processable.options[:dependencies]&.empty?
      end

      def jobs_from_previous_stages
        processable.pipeline.builds
          .latest
          .before_stage(processable.stage_idx)
      end

      def jobs_from_needs(scope)
        return scope unless Feature.enabled?(:ci_dag_support, project, default_enabled: true)
        return scope unless processable.scheduling_type_dag?

        needs_names = processable.needs.artifacts.select(:name)
        scope.where(name: needs_names)
      end

      def jobs_from_dependencies(scope)
        return scope unless processable.options[:dependencies].present?

        scope.where(name: processable.options[:dependencies])
      end
    end
  end
end

Ci::Processable::Dependencies.prepend_if_ee('EE::Ci::Processable::Dependencies')
