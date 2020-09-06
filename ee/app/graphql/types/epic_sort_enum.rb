# frozen_string_literal: true

module Types
  class EpicSortEnum < BaseEnum
    graphql_name 'EpicSort'
    description 'Roadmap sort values'

    value 'START_DATE_DESC', value: 'start_date_desc', description: 'Start date at descending order'
    value 'START_DATE_ASC', value: 'start_date_asc', description: 'Start date at ascending order'
    value 'END_DATE_DESC', value: 'end_date_desc', description: 'End date at descending order'
    value 'END_DATE_ASC', value: 'end_date_asc', description: 'End date at ascending order'

    # Deprecated:
    value 'start_date_desc', 'Start date at descending order', deprecated: { reason: 'Use START_DATE_DESC', milestone: '13.4' }
    value 'start_date_asc', 'Start date at ascending order', deprecated: { reason: 'Use START_DATE_ASC', milestone: '13.4' }
    value 'end_date_desc', 'End date at descending order', deprecated: { reason: 'Use END_DATE_DESC', milestone: '13.4' }
    value 'end_date_asc', 'End date at ascending order', deprecated: { reason: 'Use END_DATE_ASC', milestone: '13.4' }
  end
end
