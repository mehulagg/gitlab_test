# frozen_string_literal: true

RSpec.shared_examples 'cluster metrics' do
  include AccessMatchersForController

  describe 'GET #prometheus_proxy' do
    let(:prometheus_proxy_service) { instance_double(Prometheus::ProxyService) }
    let(:expected_params) do
      ActionController::Parameters.new(
        prometheus_proxy_params(
          proxy_path: 'query',
          controller: subject.controller_path,
          action: 'prometheus_proxy'
        )
      ).permit!
    end

    before do
      sign_in(user)
    end

    context 'with valid requests' do
      before do
        allow(Prometheus::ProxyService).to receive(:new)
          .with(cluster, 'GET', 'query', expected_params)
          .and_return(prometheus_proxy_service)

        allow(prometheus_proxy_service).to receive(:execute)
          .and_return(service_result)
      end

      context 'with success result' do
        let(:service_result) { { status: :success, body: prometheus_body } }
        let(:prometheus_body) { '{"status":"success"}' }

        it 'returns prometheus response' do
          prometheus_json_body = Gitlab::Json.parse(prometheus_body)

          get :prometheus_proxy, params: prometheus_proxy_params

          expect(Prometheus::ProxyService).to have_received(:new)
            .with(cluster, 'GET', 'query', expected_params)
          expect(response).to have_gitlab_http_status(:ok)
          expect(json_response).to eq(prometheus_json_body)
        end
      end

      context 'with nil result' do
        let(:service_result) { nil }

        it 'returns 204 no content' do
          get :prometheus_proxy, params: prometheus_proxy_params

          expect(json_response['status']).to eq('processing')
          expect(json_response['message']).to eq('Not ready yet. Try again later.')
          expect(response).to have_gitlab_http_status(:no_content)
        end
      end

      context 'with 404 result' do
        let(:service_result) { { http_status: 404, status: :success, body: '{"body": "value"}' } }

        it 'returns body' do
          get :prometheus_proxy, params: prometheus_proxy_params

          expect(response).to have_gitlab_http_status(:not_found)
          expect(json_response['body']).to eq('value')
        end
      end

      context 'with error result' do
        context 'with http_status' do
          let(:service_result) do
            { http_status: :service_unavailable, status: :error, message: 'error message' }
          end

          it 'sets the http response status code' do
            get :prometheus_proxy, params: prometheus_proxy_params

            expect(response).to have_gitlab_http_status(:service_unavailable)
            expect(json_response['status']).to eq('error')
            expect(json_response['message']).to eq('error message')
          end
        end

        context 'without http_status' do
          let(:service_result) { { status: :error, message: 'error message' } }

          it 'returns bad_request' do
            get :prometheus_proxy, params: prometheus_proxy_params

            expect(response). to have_gitlab_http_status(:bad_request)
            expect(json_response['status']).to eq('error')
            expect(json_response['message']).to eq('error message')
          end
        end
      end
    end

    context 'with inappropriate requests' do
      context 'without correct permissions' do
        let(:user2) { create(:user) }

        before do
          sign_out(user)
          sign_in(user2)
        end

        it 'returns 404' do
          get :prometheus_proxy, params: prometheus_proxy_params

          expect(response).to have_gitlab_http_status(:not_found)
        end
      end
    end
  end

  shared_examples 'the default dashboard' do
    it 'returns a json object with the correct keys' do
      get :metrics_dashboard, params: metrics_params, format: :json

      expect(response).to have_gitlab_http_status(:ok)
      expect(json_response.keys).to contain_exactly('dashboard', 'status', 'metrics_data')
    end

    it 'is the default dashboard' do
      get :metrics_dashboard, params: metrics_params, format: :json

      expect(json_response['dashboard']['dashboard']).to eq('Cluster health')
    end
  end

  private

  def go
    get :metrics, params: metrics_params, format: :json
  end
end
