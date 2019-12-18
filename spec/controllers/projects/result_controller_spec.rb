# frozen_string_literal: true

require 'spec_helper'

describe Projects::ResultController do
  let(:user) { project.owner }
  let_it_be(:project) { create(:project, :repository, :public) }

  let_it_be(:pipeline, reload: true) do
    create(:ci_pipeline,
           project: project,
           sha: project.commit.sha,
           ref: project.default_branch,
           status: 'success')
  end

  let!(:job) { create(:ci_build, :success, :artifacts, pipeline: pipeline) }

  before do
    sign_in(user)
  end

  describe 'GET index' do
    subject { get :index, params: { namespace_id: project.namespace, project_id: project } }

    context 'when feature flag is on' do
      before do
        stub_feature_flag(job_results: true)
      end

      it 'sets the results variable' do
        subject

        expect(assigns(:results)).to contain_exactly(*job.results)
      end
    end
  end
end
