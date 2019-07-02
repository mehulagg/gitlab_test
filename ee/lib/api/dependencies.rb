# frozen_string_literal: true

module API
  class Dependencies < Grape::API
    before do
      authenticate!
    end

    params do
      requires :id, type: String, desc: 'The ID of a project'
    end

    resource :projects, requirements: API::NAMESPACE_OR_PROJECT_REQUIREMENTS do
      desc 'Get a list of project dependencies' do
        success ::EE::API::Entities::Dependency
      end

      get ':id/dependencies' do
        pipeline = user_project.all_pipelines.latest_successful_for(user_project.default_branch)
        dependencies = ::Security::DependencyListService.new(pipeline: pipeline, params: {}).execute

        present dependencies, with: ::EE::API::Entities::Dependency
      end
    end
  end
end
