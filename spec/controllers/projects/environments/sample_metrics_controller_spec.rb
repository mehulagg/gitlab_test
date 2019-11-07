# frozen_string_literal: true

require 'spec_helper'

describe Projects::Environments::SampleMetricsController do
  let_it_be(:project) { create(:project) }
  let_it_be(:environment) { create(:environment, project: project) }
  let_it_be(:user) { create(:user) }

  before do
    project.add_reporter(user)
    sign_in(user)
  end

  describe 'GET #query' do
    let(:expected_params) do
      ActionController::Parameters.new(
        environment_params(
          controller: 'projects/environments/sample_metrics',
          action: 'query'
        )
      ).permit!
    end

    context 'when the file is not found' do
      before do
        get :query, params: environment_params
      end

      it 'returns a 404' do
        expect(response).to have_gitlab_http_status(:not_found)
      end
    end

    context 'when the sample data is found' do
      before do
        allow_any_instance_of(Metrics::SampleMetricsService).to receive(:query).and_return([])
        get :query, params: environment_params
      end

      it 'returns a 200 status code' do
        expect(response).to have_gitlab_http_status(:ok)
      end

      it 'returns JSON with a message' do
        expect(json_response.keys).to contain_exactly('status', 'data')
      end
    end
  end

  private

  def environment_params(params = {})
    {
      id: environment.id.to_s,
      namespace_id: project.namespace.full_path,
      project_id: project.name,
      identifier: 'sample_metric_query_result'
    }.merge(params)
  end
end
