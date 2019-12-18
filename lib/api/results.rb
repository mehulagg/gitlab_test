# frozen_string_literal: true

module API
  class Results < Grape::API
    include PaginationParams

    before { authenticate! }

    params do
      requires :id, type: String, desc: 'The ID of a project'
    end

    resource :projects, requirements: API::NAMESPACE_OR_PROJECT_REQUIREMENTS do
      desc 'Get a jobs results' do
        success Entities::Result
      end

      params do
        use :pagination
      end

      get ':id/jobs/:job_id/results' do
        authorize_read_builds!

        results = find_build!(params[:job_id]).results

        present results, with: Entities::Result
      end

      desc 'Get a specific result of a job' do
        success Entities::Result
      end
      params do
        requires :job_id, type: Integer, desc: 'The ID of a job'
        requires :job_id, type: Integer, desc: 'The ID of the result'
      end
      get ':id/jobs/:job_id/:id' do
        authorize_read_builds!

        result = find_build!(params[:job_id]).find(params[:result_id])

        present result, with: Entities::Result
      end
    end
  end
end
