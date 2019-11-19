# frozen_string_literal: true

module Gitlab
  module ImportExport
    module V0_2_4 # rubocop:disable Naming/ClassAndModuleCamelCase
      class ProjectTreeRestorer < Gitlab::ImportExport::ProjectTreeRestorer
        extend ::Gitlab::Utils::Override
        # A Hash of the imported merge request ID -> imported ID.
        def merge_requests_mapping
          @merge_requests_mapping ||= {}
        end

        override :process_project_relation_item!
        def process_project_relation_item!(relation_key, relation_definition, data_hash)
          relation_object = build_relation(relation_key, relation_definition, data_hash)
          return unless relation_object
          return if group_model?(relation_object)

          relation_object.project = @project
          relation_object.save!

          save_id_mapping(relation_key, data_hash, relation_object)
        end

        override :rename
        def restore
          begin
            @tree_hash = read_tree_hash
          rescue => e
            Rails.logger.error("Import/Export error: #{e.message}") # rubocop:disable Gitlab/RailsLogger
            raise Gitlab::ImportExport::Error.new('Incorrect JSON format')
          end

          @project_members = @tree_hash.delete('project_members')

          RelationRenameService.rename(@tree_hash)

          ActiveRecord::Base.uncached do
            ActiveRecord::Base.no_touching do
              update_project_params!
              create_project_relations!
              post_import!
            end
          end
        end

        # Older, serialized CI pipeline exports may only have a
        # merge_request_id and not the full hash of the merge request. To
        # import these pipelines, we need to preserve the mapping between
        # the old and new the merge request ID.
        def save_id_mapping(relation_key, data_hash, relation_object)
          return unless relation_key == 'merge_requests'

          merge_requests_mapping[data_hash['id']] = relation_object.id
        end

        override :build_relation
        def build_relation(relation_key, relation_definition, data_hash)
          # TODO: This is hack to not create relation for the author
          # Rather make `RelationFactory#set_note_author` to take care of that
          return data_hash if relation_key == 'author'

          # create relation objects recursively for all sub-objects
          relation_definition.each do |sub_relation_key, sub_relation_definition|
            transform_sub_relations!(data_hash, sub_relation_key, sub_relation_definition)
          end

          RelationFactory.create(
            relation_sym: relation_key.to_sym,
            relation_hash: data_hash,
            members_mapper: members_mapper,
            merge_requests_mapping: merge_requests_mapping,
            user: @user,
            project: @project,
            excluded_keys: excluded_keys_for_relation(relation_key))
        end


      end
    end
  end
end
