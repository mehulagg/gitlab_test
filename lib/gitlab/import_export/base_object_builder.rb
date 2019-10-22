# frozen_string_literal: true

module Gitlab
  module ImportExport
    # Base class for Group & Project Object Builders.
    # This class is not intended to be used on it's own but
    # rather inherited from.
    class BaseObjectBuilder
      def self.build(*args)
        new(*args).build
      end

      def initialize(klass, attributes)
        @klass = klass.ancestors.include?(Label) ? Label : klass
        @attributes = attributes
      end

      def build
        define_where_clauses

        object = find_object

        return object if find_object

        prepared_attributes = prepare_attributes

        create_object(prepared_attributes)
      end

      protected

      def define_where_clauses
        @where_clauses ||= where_clauses
      end

      def where_clauses
        # to be defined in sub-class
        raise NotImplementedError
      end

      def prepare_attributes
        attributes
      end

      private

      attr_reader :klass, :attributes

      def find_object
        klass.where(where_clause).first
      end

      def where_clause
        @where_clauses.reduce(:and)
      end

      def create_object(attributes)
        klass.create(attributes)
      end

      # Returns Arel clause:
      # `"{table_name}"."{attrs.keys[0]}" = '{attrs.values[0]} AND {table_name}"."{attrs.keys[1]}" = '{attrs.values[1]}"`
      # from the given Hash of attributes.
      def attrs_to_arel(attrs)
        attrs.map do |key, value|
          table[key].eq(value)
        end.reduce(:and)
      end

      def table
        @table ||= klass.arel_table
      end

      def where_clause_base
        # to be defined in sub-class
        raise NotImplementedError
      end

      # Returns Arel clause `"{table_name}"."title" = '{attributes['title']}'`
      # if attributes has 'title key, otherwise `nil`.
      def where_clause_for_title
        attrs_to_arel(attributes.slice('title'))
      end

      # Returns Arel clause `"{table_name}"."description" = '{attributes['description']}'`
      # if attributes has 'description key, otherwise `nil`.
      def where_clause_for_description
        attrs_to_arel(attributes.slice('description'))
      end

      # Returns Arel clause `"{table_name}"."created_at" = '{attributes['created_at']}'`
      # if attributes has 'created_at key, otherwise `nil`.
      def where_clause_for_created_at
        attrs_to_arel(attributes.slice('created_at'))
      end
    end
  end
end
