# frozen_string_literal: true

module Resolvers
  module Security
  class DependencyResolver < BaseResolver
    type [Types::Security::DependencyType], null: true

    argument :packager, GraphQL::STRING_TYPE, required: false,
             description: 'Filter by package manager'

    def resolve(**args)
      #can read dependencies?
      report_service = ::Security::ReportFetchService.new(object, ::Ci::JobArtifact.dependency_list_reports)
      pipeline = report_service.pipeline
      params = {package_manager: args[:packager]}
      ::Security::DependencyListService.new(pipeline: pipeline, params: params).execute
    end
  end
  end
end
