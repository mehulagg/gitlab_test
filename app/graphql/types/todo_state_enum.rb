# frozen_string_literal: true

module Types
  class TodoStateEnum < BaseEnum
    value 'pending'
    value 'done'
    value 'closed'
  end
end
