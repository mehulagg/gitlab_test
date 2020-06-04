# frozen_string_literal: true

require 'spec_helper'

describe API::Runner do
  let_it_be(:project) { create(:project, :repository) }

  describe '/api/v4/jobs' do
    let(:runner) { create(:ci_runner, :project, projects: [project]) }

    describe 'POST /api/v4/jobs/request' do
      context 'secrets management' do
        let(:pipeline) { create(:ci_pipeline, project: project, ref: 'master') }
        let(:valid_secrets) do
          {
            DATABASE_PASSWORD: {
              vault: {
                engine: { name: 'kv-v2', path: 'kv-v2' },
                path: 'production/db',
                field: 'password'
              }
            }
          }
        end

        before do
          create(:ci_build, pipeline: pipeline, secrets: secrets)
        end

        context 'when ci_secrets_management_vault feature flag is enabled' do
          before do
            stub_feature_flags(ci_secrets_management_vault: true)
          end

          context 'when secrets management feature is available' do
            before do
              stub_licensed_features(ci_secrets_management: true)
            end

            context 'job has secrets configured' do
              let(:secrets) { valid_secrets }

              it 'returns secrets configuration' do
                request_job_with_secrets_supported

                expect(response).to have_gitlab_http_status(:created)
                expect(json_response['secrets']).to eq(
                  {
                    'DATABASE_PASSWORD' => {
                      'vault' => {
                        'engine' => { 'name' => 'kv-v2', 'path' => 'kv-v2' },
                        'path' => 'production/db',
                        'field' => 'password'
                      }
                    }
                  }
                )
              end

              context 'runner does not support secrets' do
                it 'does not expose the build at all' do
                  request_job

                  expect(response).to have_gitlab_http_status(:no_content)
                end
              end
            end

            context 'job does not have secrets configured' do
              let(:secrets) { {} }

              it 'doesn not return secrets configuration' do
                request_job_with_secrets_supported

                expect(response).to have_gitlab_http_status(:created)
                expect(json_response['secrets']).to eq(nil)
              end
            end
          end

          context 'when secrets management feature is not available' do
            before do
              stub_licensed_features(ci_secrets_management: false)
            end

            context 'job has secrets configured' do
              let(:secrets) { valid_secrets }

              it 'doesn not return secrets configuration' do
                request_job_with_secrets_supported

                expect(response).to have_gitlab_http_status(:created)
                expect(json_response['secrets']).to eq(nil)
              end
            end
          end
        end

        context 'when ci_secrets_management_vault feature flag is disabled' do
          before do
            stub_feature_flags(ci_secrets_management_vault: false)
            stub_licensed_features(ci_secrets_management: true)
          end

          context 'job has secrets configured' do
            let(:secrets) { valid_secrets }

            it 'doesn not return secrets configuration' do
              request_job_with_secrets_supported

              expect(response).to have_gitlab_http_status(:created)
              expect(json_response['secrets']).to eq(nil)
            end
          end

          context 'job does not secrets configured' do
            let(:secrets) { {} }

            it 'doesn not return secrets configuration' do
              request_job_with_secrets_supported

              expect(response).to have_gitlab_http_status(:created)
              expect(json_response['secrets']).to eq(nil)
            end
          end
        end

        def request_job_with_secrets_supported
          request_job info: { features: { secrets: true } }
        end
      end

      def request_job(token = runner.token, **params)
        post api('/jobs/request'), params: params.merge(token: token)
      end
    end
  end
end
