# frozen_string_literal: true

# Stores stable methods for ApplicationClassProxy
# which is unlikely to change from version to version.
module Elastic
  module ClassProxyUtil
    extend ActiveSupport::Concern

    def initialize(target, index)
      super(target)

      config = version_namespace.const_get('Config', false)

      @es_index = index
      @document_type = config.document_type
      @settings = config.settings
      @mapping = config.mapping
    end

    ### Multi-version utils

    alias_method :real_class, :class
    attr_reader :es_index

    def index_name
      es_index.name
    end

    def client
      es_index.client
    end

    def version_namespace
      self.class.parent
    end

    class_methods do
      def methods_for_all_write_targets
        [:refresh_index!, :delete_document, :delete_child_documents]
      end

      def methods_for_one_write_target
        [:import, :create_index!, :delete_index!]
      end
    end
  end
end
