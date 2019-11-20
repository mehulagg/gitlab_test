# frozen_string_literal: true

module Types
  module DesignManagement
    class DesignImagesType < BaseObject
      graphql_name 'DesignImages'

      # I don't think authorization matters, as it happens in the Controller
      # that serves the URIs
      # authorize :read_design

      field :is_processing,
            GraphQL::BOOLEAN_TYPE,
            null: false,
            method: :sizes_processing?,
            description: 'Indicates that all image sizes for the design image have been processed'
      field :original_url,
            GraphQL::STRING_TYPE,
            null: false,
            description: 'URL of the original sized design image'
      field :small_url,
            GraphQL::STRING_TYPE,
            null: true,
            description: 'URL of the small sized design image. Can be null when size has not yet been generated'

    end
  end
end
