# frozen_string_literal: true

module Operations
  class Strategy < ApplicationRecord
    self.table_name = 'operations_strategies'

    belongs_to :feature_flag, class_name: 'Operations::FeatureFlag'
    has_many :scopes, class_name: 'Operations::Scope'

    accepts_nested_attributes_for :scopes
  end
end
