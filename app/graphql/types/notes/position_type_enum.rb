# frozen_string_literal: true

module Types
  module Notes
    class PositionTypeEnum < BaseEnum
      graphql_name 'DiffPositionType'
      description 'Type of file the position refers to'

      value 'TEXT', value: 'text'
      value 'IMAGE', value: 'image'

      # Deprecated:
      value 'text', deprecated: { reason: 'Use TEXT', milestone: '13.4' }
      value 'image', deprecated: { reason: 'Use IMAGE', milestone: '13.4' }
    end
  end
end
