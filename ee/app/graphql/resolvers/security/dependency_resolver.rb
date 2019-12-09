# frozen_string_literal: true

module Resolvers
  module Security
  class DependencyResolver < BaseResolver
    type [Types::Security::DependencyType], null: true

    argument :project_id, GraphQL::ID_TYPE, required: true,
             description: 'id of project which dependencies are queried'

    def resolve(**args)
      project = ::Project.find(args[:project_id])
      pp project.id
      report_service = ::Security::ReportFetchService.new(project, ::Ci::JobArtifact.dependency_list_reports)
      pipeline = report_service.pipeline
      ::Security::DependencyListService.new(pipeline: pipeline, params: {}).execute
    end
  end
  end
end
