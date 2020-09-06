# frozen_string_literal: true

module Types
  module BlobViewers
    class TypeEnum < BaseEnum
      graphql_name 'BlobViewersType'
      description 'Types of blob viewers'

      value 'RICH', value: :rich
      value 'SIMPLE', value: :simple
      value 'AUXILIARY', value: :auxiliary

      # Deprecated:
      value 'rich', value: :rich, deprecated: { reason: 'Use RICH', milestone: '13.4' }
      value 'simple', value: :simple, deprecated: { reason: 'Use SIMPLE', milestone: '13.4' }
      value 'auxiliary', value: :auxiliary, deprecated: { reason: 'Use AUXILIARY', milestone: '13.4' }
    end
  end
end
