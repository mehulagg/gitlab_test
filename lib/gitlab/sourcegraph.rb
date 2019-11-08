# frozen_string_literal: true

module Gitlab
  class Sourcegraph
    def self.feature_conditional?
      self.feature.conditional?
    end

    def self.feature_available?
      # The sourcegraph_bundle feature could be conditionally applied, so check if `!off?`
      !self.feature.off?
    end

    def self.feature_enabled?(thing = true)
      self.feature.enabled?(thing)
    end

    private

    def self.feature
      Feature.get(:sourcegraph)
    end
  end
end
