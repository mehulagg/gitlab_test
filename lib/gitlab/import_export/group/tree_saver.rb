# frozen_string_literal: true

module Gitlab
  module ImportExport
    module Group
      class TreeSaver
        attr_reader :shared

        def initialize(group:, current_user:, shared:, params: {})
          @params       = params
          @current_user = current_user
          @shared       = shared
          @group        = group
          @json_writers = {}
        end

        def save
          @group.self_and_descendants.order('parent_id ASC NULLS FIRST').map do |group|
            serializer = ImportExport::JSON::StreamingSerializer.new(group, reader.group_tree, json_writer(group.parent_id.to_s))
            serializer.execute
          end

          true
        rescue => e
          @shared.error(e)
          false
        ensure
          @json_writers.values.each(&:close)
        end

        private

        def reader
          @reader ||= Gitlab::ImportExport::Reader.new(
            shared: @shared,
            config: Gitlab::ImportExport::Config.new(
              config: Gitlab::ImportExport.group_config_flat_file
            ).to_h
          )
        end

        def json_writer(group_path)
          if !::Feature.enabled?(:ndjson_import_export, @project)
            @json_writers[group_path] ||= begin
              full_path = File.join(@shared.export_path, 'tree', group_path)
              Gitlab::ImportExport::JSON::NdjsonWriter.new(full_path, :group)
            end
          else
            @json_writers[:legacy] ||= begin
              full_path = File.join(@shared.export_path, ImportExport.project_filename)
              Gitlab::ImportExport::JSON::LegacyWriter.new(full_path)
            end
          end
        end
      end
    end
  end
end
