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
        success ::EE::API::Entities::DependencyEntity
      end

      get ':id/dependencies' do
        # authorize! :read_dependency_list, user_project

        dependencies = 'FindDependenciesService'

        present paginate(dependencies), with: ::EE::API::DependencyEntity
      end
    end
  end
end
