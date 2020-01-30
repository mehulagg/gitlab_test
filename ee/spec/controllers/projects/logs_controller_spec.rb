# frozen_string_literal: true

require 'spec_helper'

describe Projects::LogsController do
  include KubernetesHelpers

  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project) }

  let_it_be(:environment) do
    create(:environment, name: 'production', project: project)
  end

  let(:pod_name) { "foo" }
  let(:container) { 'container-1' }

  before do
    project.add_maintainer(user)

    sign_in(user)
  end

  describe 'GET #index' do
    context 'when unlicensed' do
      before do
        stub_licensed_features(pod_logs: false)
      end

      it 'renders forbidden' do
        get :index, params: environment_params

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end

    context 'when licensed' do
      before do
        stub_licensed_features(pod_logs: true)
      end

      let(:empty_project) { create(:project) }

      it 'renders empty logs page if no environment exists' do
        empty_project.add_maintainer(user)
        get :index, params: { namespace_id: empty_project.namespace, project_id: empty_project }

        expect(response).to be_ok
        expect(response).to render_template 'empty_logs'
      end

      it 'renders index template' do
        get :index, params: environment_params

        expect(response).to be_ok
        expect(response).to render_template 'index'
      end
    end
  end

  def environment_params(opts = {})
    opts.reverse_merge(namespace_id: project.namespace,
                       project_id: project,
                       environment_name: environment.name)
  end
end
