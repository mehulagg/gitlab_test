# frozen_string_literal: true

module API
  module Entities
    class Bridge < Entities::JobBasic
      expose :yaml_variables
    end
  end
end
