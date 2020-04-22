# frozen_string_literal: true

module Gitlab
  module ImportExport
    class AttributesPermitter
      attr_reader :permitted_attributes

      PERMITTED_MODELS = %i(issues merge_requests)

      def initialize(config: ImportExport::Config.new.to_h)
        @config = config
        @attributes_finder = Gitlab::ImportExport::AttributesFinder.new(config: @config)
        @permitted_attributes = {}

        build_permitted_attributes
      end

      def permit(relation_name, relation_hash)
        # only filter specific models for now
        return relation_hash unless PERMITTED_MODELS.include?(relation_name)

        permitted_attributes = permitted_attributes_for(relation_name)

        relation_hash.select do |key, _|
          permitted_attributes.include?(key)
        end
      end

      def permitted_attributes_for(relation_name)
        @permitted_attributes[relation_name] || []
      end

      private

      def build_permitted_attributes
        build_associations
        build_attributes
        build_methods
      end

      # Deep traverse relations tree to build a list of allowed model relations
      def build_associations
        stack = @attributes_finder.tree.map { |model_name, relations| [model_name, relations] }

        while stack.any?
          model_name, relations = stack.pop

          @permitted_attributes[model_name] ||= []

          if relations.is_a? Hash
            @permitted_attributes[model_name].concat(relations.keys) if relations.keys.any?

            relations.each { |model, relation_list| stack.push([model, relation_list]) }
          end
        end

        @permitted_attributes
      end

      def build_attributes
        included_attributes = @attributes_finder.included_attributes
        shared_included_attributes = @attributes_finder.shared_included_attributes

        included_attributes.each do |model_name, attributes|
          @permitted_attributes[model_name] ||= []

          @permitted_attributes[model_name].concat(attributes)
          @permitted_attributes[model_name].concat(shared_included_attributes)
        end
      end

      def build_methods
        methods = @attributes_finder.methods

        methods.each do |model_name, method_list|
          @permitted_attributes[model_name] ||= []

          @permitted_attributes[model_name].concat(method_list)
        end
      end
    end
  end
end
