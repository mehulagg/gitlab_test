# frozen_string_literal: true

module Resolvers
  module DesignManagement
    class VersionResolver < BaseResolver
      type Types::DesignManagement::VersionType.connection_type, null: false

      alias_method :design_or_collection, :object

      argument :as_of, Types::TimeType, required: false

      def resolve(as_of:)
        unless Ability.allowed?(context[:current_user], :read_design, design_or_collection)
          return ::DesignManagement::Version.none
        end

        versions = design_or_collection.versions.ordered
        if as_of.present?
          versions.as_of(as_of)
        else
          versions
        end
      end
    end
  end
end
