# frozen_string_literal: true

require 'spec_helper'

describe API::Clusters do
  shared_examples 'logs endpoint' do |endpoint|
    let(:user) { create(:user) }
    let(:environment) { create(:environment) }
    let(:cluster) { create(:cluster, :provided_by_gcp, environment_scope: '*', projects: [environment.project]) }
    let(:kubernetes_namespace) { create(:cluster_kubernetes_namespace, environment: environment, cluster: cluster) }
    let(:url) { "/clusters/#{cluster.id}/namespace/#{kubernetes_namespace.namespace}/logs/#{endpoint}?#{params.to_query}" }

    context 'without access to the project' do
      it 'returns 404' do
        get api(url, user)
        expect(response).to have_gitlab_http_status(404)
      end
    end

    context 'with developer access to the project' do
      it 'returns 404' do
        environment.project.add_user(user, Gitlab::Access::DEVELOPER)
        get api(url, user)
        expect(response).to have_gitlab_http_status(404)
      end
    end

    context 'with maintainer access to the project' do
      before do
        environment.project.add_user(user, Gitlab::Access::MAINTAINER)
      end

      context 'when pod_logs is not licensed' do
        it 'returns 404' do
          get api(url, user)
          expect(response).to have_gitlab_http_status(404)
        end
      end

      context 'when pod_logs is licensed' do
        before do
          stub_licensed_features(pod_logs: true)
        end

        context 'when environment does not exist' do
          let(:url) { "/clusters/0/namespace/foo/logs/#{endpoint}" }

          it 'returns 404' do
            get api(url, user)
            expect(response).to have_gitlab_http_status(404)
          end
        end

        context 'when service is processing' do
          before do
            service = instance_double(PodLogsService)
            expect(PodLogsService).to receive(:new).with(environment, params: hash_including(params)).and_return(service)
            expect(service).to receive(:execute).and_return(status: :processing)
          end

          it 'returns 202' do
            get api(url, user)
            expect(response).to have_gitlab_http_status(202)
          end
        end

        context 'when service is returning an error' do
          before do
            service = instance_double(PodLogsService)
            expect(PodLogsService).to receive(:new).with(environment, params: hash_including(params)).and_return(service)
            expect(service).to receive(:execute).and_return(status: :error, message: 'an error occured', last_step: 'foo')
          end

          it 'returns 400 with the error message' do
            get api(url, user)
            expect(response).to have_gitlab_http_status(400)
            expect(json_response['message']).to eq('an error occured (last_step: foo)')
            expect(json_response['status']).to eq('error')
            expect(json_response.keys).to contain_exactly('message', 'status')
          end
        end

        context 'when service is returning logs successfully' do
          before do
            service = instance_double(PodLogsService)
            expect(PodLogsService).to receive(:new).with(environment, params: hash_including(params)).and_return(service)
            expect(service).to receive(:execute).and_return(status: :success, logs: %w[foo bar])
          end

          it 'returns 200 with the result' do
            get api(url, user)
            expect(response).to have_gitlab_http_status(200)
            expect(json_response).to eq({ 'status' => 'success', 'logs' => %w[foo bar] })
          end

          it 'registers a usage of the endpoint' do
            expect(::Gitlab::UsageCounters::PodLogs).to receive(:increment).with(environment.project.id)
            get api(url, user)
          end

          it 'sets the polling header' do
            get api(url, user)
            expect(response.headers['Poll-Interval']).to eq('3000')
          end
        end
      end
    end
  end

  describe 'GET /clusters/:id/namespace/:namespace/logs/kubernetes' do
    let(:params) do
      {
        'pod_name' => 'pod-1',
        'container_name' => 'foo'
      }
    end

    it_behaves_like 'logs endpoint', :kubernetes
  end

  describe 'GET /clusters/:id/namespace/:namespace/logs/elasticsearch' do
    let(:params) do
      {
        'pod_name' => 'pod-1',
        'container_name' => 'foo',
        'search' => 'bar',
        'start' => '2020-01-30T15:55:18.000Z',
        'end' => '2020-01-30T16:55:18.000Z'
      }
    end

    it_behaves_like 'logs endpoint', :elasticsearch
  end
end
