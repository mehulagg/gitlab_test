# frozen_string_literal: true

module Resolvers
  module Security
  class DependencyResolver < BaseResolver
    type [Types::Security::DependencyType], null: true

    def resolve(**args)
      #can read dependencies?
      report_service = ::Security::ReportFetchService.new(object, ::Ci::JobArtifact.dependency_list_reports)
      pipeline = report_service.pipeline
      ::Security::DependencyListService.new(pipeline: pipeline, params: {}).execute
    end
  end
  end
end
