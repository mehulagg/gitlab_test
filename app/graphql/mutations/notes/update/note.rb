# frozen_string_literal: true

module Mutations
  module Notes
    module Update
      class Note < Mutations::Notes::Update::Base
        graphql_name 'UpdateNote'

        argument :body,
                  GraphQL::STRING_TYPE,
                  required: false,
                  description: copy_field_description(Types::Notes::NoteType, :body)

        argument :confidential,
                  GraphQL::BOOLEAN_TYPE,
                  required: false,
                  description: 'The confidentiality flag of a note. Default is false.'
      end
    end
  end
end
