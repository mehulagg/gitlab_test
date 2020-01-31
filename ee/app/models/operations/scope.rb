# frozen_string_literal: true

module Operations
  class Scope < ApplicationRecord
    self.table_name = 'operations_scopes'

    belongs_to :strategy, class_name: 'Operations::Strategy'
  end
end
