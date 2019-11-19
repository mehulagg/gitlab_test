# frozen_string_literal: true

module Gitlab
  module ImportExport
    module V0_2_4 # rubocop:disable Naming/ClassAndModuleCamelCase
      class RelationFactory < Gitlab::ImportExport::RelationFactory
        extend ::Gitlab::Utils::Override

        override :initialize
        def initialize(relation_sym:, relation_hash:, members_mapper:, merge_requests_mapping:, user:, project:, excluded_keys: [])
          super

          @merge_requests_mapping = merge_requests_mapping
        end

        private

        override :setup_models
        def setup_models
          case @relation_name
          when :merge_request_diff_files       then setup_diff
          when :notes                          then setup_note
          end

          update_user_references
          update_project_references
          update_group_references
          remove_duplicate_assignees
          if @relation_name == :'Ci::Pipeline'
            update_merge_request_references
            setup_pipeline
          end

          reset_tokens!
          remove_encrypted_attributes!
        end

        # This code is a workaround for broken project exports that don't
        # export merge requests with CI pipelines (i.e. exports that were
        # generated from
        # https://gitlab.com/gitlab-org/gitlab/merge_requests/17844).
        # This method can be removed in GitLab 12.6.
        def update_merge_request_references
          # If a merge request was properly created, we don't need to fix
          # up this export.
          return if @relation_hash['merge_request']

          merge_request_id = @relation_hash['merge_request_id']

          return unless merge_request_id

          new_merge_request_id = @merge_requests_mapping[merge_request_id]

          return unless new_merge_request_id

          @relation_hash['merge_request_id'] = new_merge_request_id
          parsed_relation_hash['merge_request_id'] = new_merge_request_id
        end

      end
    end
  end
end
