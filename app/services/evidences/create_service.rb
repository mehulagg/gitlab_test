# frozen_string_literal: true

module Evidences
  class CreateService
    attr_reader :release

    def initialize(release)
      @release = release
    end

    def execute
      raise(StandardError, 'Release is empty') unless release

      evidence = build_evidence
      evidence.save!
    end

    private

    def build_evidence
      release.evidences.build(summary: generate_summary)
    end

    def generate_summary
      Evidences::EvidenceSerializer.new.represent(Evidence.new(release: release)) # rubocop: disable CodeReuse/Serializer
    end
  end
end
