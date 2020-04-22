# frozen_string_literal: true

module Types
  class ReleaseAssetsType < BaseObject
    graphql_name 'ReleaseAssets'

    authorize :read_release

    alias_method :release, :object

    present_using ReleasePresenter

    field :assets_count, GraphQL::INT_TYPE, null: true,
          description: 'The number of assets attached to the release'
    field :links, [Types::ReleaseLinkType], null: true,
          description: 'Links associated to the release'
    field :sources, [Types::ReleaseSourceType], null: true,
          description: 'Sources associated wih the release'
    field :evidence_file_path, GraphQL::STRING_TYPE, null: true,
          description: "URL to the release's evidence"
  end
end
