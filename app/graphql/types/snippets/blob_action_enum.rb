# frozen_string_literal: true

module Types
  module Snippets
    class BlobActionEnum < BaseEnum
      graphql_name 'SnippetBlobActionEnum'
      description 'Type of a snippet blob input action'

      value 'CREATE', value: :create
      value 'UPDATE', value: :update
      value 'DELETE', value: :delete
      value 'MOVE', value: :move

      # Deprecated:
      value 'create', value: :create, deprecated: { reason: 'Use CREATE', milestone: '13.4' }
      value 'update', value: :update, deprecated: { reason: 'Use UPDATE', milestone: '13.4' }
      value 'delete', value: :delete, deprecated: { reason: 'Use DELETE', milestone: '13.4' }
      value 'move', value: :move, deprecated: { reason: 'Use MOVE', milestone: '13.4' }
    end
  end
end
