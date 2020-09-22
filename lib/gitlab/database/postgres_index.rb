# frozen_string_literal: true

module Gitlab
  module Database
    class PostgresIndex < ApplicationRecord
      self.table_name = 'postgres_indexes'
      self.primary_key = 'identifier'

      alias_attribute :unique?, :is_unique
      alias_attribute :valid?, :is_valid

      scope :by_identifier, ->(identifier) do
        raise ArgumentError, "Index name is not fully qualified with a schema: #{identifier}" unless identifier =~ /^\w+\.\w+$/

        find(identifier)
      end

      def to_s
        name
      end
    end
  end
end
