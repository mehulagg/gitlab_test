# frozen_string_literal: true

module Types
  module Snippets
    class TypeEnum < BaseEnum
      value 'PERSONAL', value: 'personal'
      value 'PROJECT', value: 'project'

      # Deprecated:
      value 'personal', deprecated: { reason: 'Use PERSONAL', milestone: '13.4' }
      value 'project', deprecated: { reason: 'Use PROJECT', milestone: '13.4' }
    end
  end
end
