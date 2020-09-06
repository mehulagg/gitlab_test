# frozen_string_literal: true

module Types
  module Snippets
    class VisibilityScopesEnum < BaseEnum
      value 'PRIVATE',  value: 'are_private'
      value 'INTERNAL', value: 'are_internal'
      value 'PUBLIC',   value: 'are_public'

      # Deprecated:
      value 'private',  value: 'are_private', deprecated: { reason: 'Use PRIVATE', milestone: '13.4' }
      value 'internal', value: 'are_internal', deprecated: { reason: 'Use INTERNAL', milestone: '13.4' }
      value 'public',   value: 'are_public', deprecated: { reason: 'Use PUBLIC', milestone: '13.4' }
    end
  end
end
