# frozen_string_literal: true

module EE
  module Types
    module NamespaceType
      extend ActiveSupport::Concern

      prepended do
        field :storage_size_limit,
              GraphQL::FLOAT_TYPE,
              null: true,
              description: 'Total storage limit of the root namespace in bytes',
              resolve: -> (obj, _args, _ctx) { EE::Namespace::RootStorageSize.new(obj).limit }

        field :is_temporary_storage_increase_enabled,
              GraphQL::BOOLEAN_TYPE,
              null: false,
              description: 'Status of the temporary storage increase',
              resolve: -> (obj, _args, _ctx) { obj.temporary_storage_increase_enabled? }

        field :is_eligible_for_temporary_storage_increase,
              GraphQL::BOOLEAN_TYPE,
              null: false,
              description: 'Eligibility for increasing storage temporarily',
              resolve: -> (obj, _args, _ctx) { obj.eligible_for_temporary_storage_increase? }

        field :temporary_storage_increase_ends_on,
              ::Types::TimeType,
              null: true,
              description: 'Date until the temporary storage increase is active'
      end
    end
  end
end
