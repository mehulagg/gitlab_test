# frozen_string_literal: true

module Types
  module Tree
    class TypeEnum < BaseEnum
      graphql_name 'EntryType'
      description 'Type of a tree entry'

      value 'TREE', value: :tree
      value 'BLOB', value: :blob
      value 'COMMIT', value: :commit

      # Deprecated:
      value 'tree', value: :tree, deprecated: { reason: 'Use TREE', milestone: '13.4' }
      value 'blob', value: :blob, deprecated: { reason: 'Use BLOB', milestone: '13.4' }
      value 'commit', value: :commit, deprecated: { reason: 'Use COMMIT', milestone: '13.4' }
    end
  end
end
