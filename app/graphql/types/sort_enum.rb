# frozen_string_literal: true

module Types
  class SortEnum < BaseEnum
    graphql_name 'Sort'
    description 'Common sort values'

    value 'UPDATED_DESC', 'Updated at descending order'
    value 'UPDATED_ASC', 'Updated at ascending order'
    value 'CREATED_DESC', 'Created at descending order'
    value 'CREATED_ASC', 'Created at ascending order'

    # Deprecated:
    value 'updated_desc', 'Updated at descending order', deprecated: { reason: 'Use UPDATED_DESC', milestone: '13.4' }
    value 'updated_asc', 'Updated at ascending order', deprecated: { reason: 'Use UPDATED_ASC', milestone: '13.4' }
    value 'created_desc', 'Created at descending order', deprecated: { reason: 'Use CREATED_DESC', milestone: '13.4' }
    value 'created_asc', 'Created at ascending order', deprecated: { reason: 'Use CREATED_ASC', milestone: '13.4' }
  end
end
