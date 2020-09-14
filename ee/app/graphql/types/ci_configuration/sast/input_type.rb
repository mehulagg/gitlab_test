# frozen_string_literal: true

module Types
  module CiConfiguration
    module Sast
      class InputType < BaseInputObject # rubocop:disable Graphql/AuthorizeTypes
        graphql_name 'SastCiConfigurationInput'
        description 'Represents a CI configuration of SAST'

        argument :global, [::Types::CiConfiguration::Sast::EntityInputType],
          description: 'List of global entities related to SAST configuration',
          required: false

        argument :pipeline, [::Types::CiConfiguration::Sast::EntityInputType],
          description: 'List of pipeline entities related to SAST configuration',
          required: false
      end
    end
  end
end
