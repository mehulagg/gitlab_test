# frozen_string_literal: true

class FeatureFlagStrategyEntity < Grape::Entity
  include RequestAwareEntity

  expose :id
  expose :name
  expose :parameters
end
