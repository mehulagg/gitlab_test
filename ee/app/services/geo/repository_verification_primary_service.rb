# frozen_string_literal: true

module Geo
  class RepositoryVerificationPrimaryService < BaseRepositoryVerificationService
    REPO_TYPE = 'repository'

    def initialize(project, repo_type)
      @project = project
    end

    def execute
      verify_checksum

      create_reset_checksum_event
    end

    private

    attr_reader :project

    def verify_checksum
      checksum = calculate_checksum(repository)
      update_repository_state!(checksum: checksum)
    rescue => e
      log_error("Error calculating the #{type} checksum", e, type: type)
      update_repository_state!(failure: e.message)
    end

    def update_repository_state!(checksum: nil, failure: nil)
      retry_at, retry_count =
        if failure.present?
          calculate_next_retry_attempt(repository_state, type)
        end

      repository_state.update!(
        "#{type}_verification_checksum" => checksum,
        "last_#{type}_verification_ran_at" => Time.now,
        "last_#{type}_verification_failure" => failure,
        "#{type}_retry_at" => retry_at,
        "#{type}_retry_count" => retry_count
      )
    end

    def create_reset_checksum_event
      Geo::ResetChecksumEventStore.new(project, resource_type: type).create!
    end

    def repository_state
      @repository_state ||= project.repository_state || project.build_repository_state
    end

    def type
      REPO_TYPE
    end

    def repository
      project.repository
    end
  end
end
