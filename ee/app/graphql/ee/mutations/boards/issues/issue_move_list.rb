# frozen_string_literal: true

module EE
  module Mutations
    module Boards
      module Issues
        module IssueMoveList
          extend ActiveSupport::Concern

          prepended do
            argument :epic_id, GraphQL::ID_TYPE,
                      required: false,
                      loads: ::Types::EpicType,
                      description: 'Global ID of the epic to be assigned to the issue'
          end

          def resolve(board:, epic:, **args)
            args[:epic] = epic if epic.present?

            super
          end

          def move_arguments(args)
            args.slice(:from_list_id, :to_list_id, :move_after_id, :move_before_id, :epic)
          end
        end
      end
    end
  end
end
