# frozen_string_literal: true

module EE
  module API
    module Helpers
      module NotesHelpers
        extend ActiveSupport::Concern

        class_methods do
          extend ::Gitlab::Utils::Override

          override :noteable_types
          def noteable_types
            [::Epic, *super]
          end
        end

        def add_parent_to_finder_params(finder_params, noteable_type)
          if noteable_type.name.underscore == 'epic'
            finder_params[:group_id] = user_group.id
          else
            super
          end
        end

        # Used only for anonymous Visual Review Tools feedback
        def find_merge_request_without_permissions_check(project, iid)
          ::MergeRequest.find_by_target_project_and_iid(project, iid) || not_found!(::MergeRequest)
        end

        def create_visual_review_note(project, opts)
          unless ::Feature.enabled?(:anonymous_visual_review_feedback)
            forbidden!('Anonymous visual review feedback is disabled')
          end

          ::Notes::CreateService.new(project, ::User.visual_review_bot, opts).execute
        end
      end
    end
  end
end
