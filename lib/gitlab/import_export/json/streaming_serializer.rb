# frozen_string_literal: true

module Gitlab
  module ImportExport
    module JSON
      class StreamingSerializer
        include Gitlab::ImportExport::CommandLineUtil

        attr_reader :overrides
        attr_reader :additional_relations

        BATCH_SIZE = 100

        class Raw < String
          def to_json
            to_s
          end
        end

        def initialize(exportable, relations_tree)
          @exportable = exportable
          @relations_tree = relations_tree
          @overrides = {}
          @additional_relations = {}
        end

        def execute(json_writers)
          serialize_root(json_writers)

          includes.each do |relation_definition|
            serialize_relation(json_writers, relation_definition)
          end
        end

        private

        def serialize_root(json_writers)
          attributes = @exportable.as_json(
            @relations_tree.merge(include: nil, preloads: nil))

          data = attributes.merge(overrides)

          json_writers.each do |saver|
            saver.set(data)
          end
        end

        def serialize_relation(json_writers, definition)
          raise ArgumentError, 'definition needs to be Hash' unless definition.is_a?(Hash)
          raise ArgumentError, 'definition needs to have exactly one Hash element' unless definition.one?

          key = definition.first.first
          options = definition.first.second

          record = @exportable.public_send(key) # rubocop: disable GitlabSecurity/PublicSend

          if record.is_a?(ActiveRecord::Relation)
            serialize_many_relations(json_writers, key, record, options)
          else
            serialize_single_relation(json_writers, key, record, options)
          end
        end

        def serialize_many_relations(json_writers, key, record, options)
          key_preloads = preloads&.dig(key)

          record.in_batches(of: BATCH_SIZE) do |batch| # rubocop:disable Cop/InBatches
            batch = batch.preload(key_preloads) if key_preloads

            batch.each do |item|
              item = Raw.new(item.to_json(options))

              json_writers.each do |saver|
                saver.append(key, item)
              end
            end
          end

          @additional_relations[key].to_a.each do |item|
            item = Raw.new(item.to_json(options))

            json_writers.each do |saver|
              saver.append(key, item)
            end
          end
        end

        def serialize_single_relation(json_writers, key, record, options)
          json = Raw.new(record.to_json(options))

          json_writers.each do |saver|
            saver.write(key, json)
          end
        end

        def includes
          @relations_tree[:include]
        end

        def preloads
          @relations_tree[:preload]
        end
      end
    end
  end
end
