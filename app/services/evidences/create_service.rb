# frozen_string_literal: true

module Evidences
  class CreateService < BaseService
    attr_reader :evidence

    def initialize(evidence)
      @evidence = evidence
    end

    def generate_summary
      Evidences::EvidenceSerializer.new.represent(evidence) # rubocop: disable CodeReuse/Serializer
    end
  end
end
