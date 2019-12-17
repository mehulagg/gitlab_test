# frozen_string_literal: true

module Geo
  module Tracking
    class GitRepositoryRegistry < Geo::BaseRegistry
      include ::Geo::TrackingStateMachine
    end
  end
end
