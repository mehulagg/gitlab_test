# frozen_string_literal: true

module EE
  module API
    module Entities
      class FlipperGate < Grape::Entity
        expose :key
        expose :name
        expose :value
      end
    end
  end
end
