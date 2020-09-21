# frozen_string_literal: true

require 'spec_helper'

RSpec.describe API::Lint do
  describe 'POST /ci/lint' do
    context 'with valid .gitlab-ci.yaml content' do
      let(:yaml_content) do
        File.read(Rails.root.join('spec/support/gitlab_stubs/gitlab_ci.yml'))
      end

      it 'passes validation' do
        post api('/ci/lint'), params: { content: yaml_content }

        expect(response).to have_gitlab_http_status(:ok)
        expect(json_response).to be_an Hash
        expect(json_response['status']).to eq('valid')
        expect(json_response['errors']).to eq([])
      end

      it 'outputs expanded yaml content' do
        post api('/ci/lint'), params: { content: yaml_content, include_merged_yaml: true }

        expect(response).to have_gitlab_http_status(:ok)
        expect(json_response).to have_key('merged_config')
      end
    end

    context 'with an invalid .gitlab_ci.yml' do
      context 'with invalid syntax' do
        let(:yaml_content) { 'invalid content' }

        it 'responds with errors about invalid syntax' do
          post api('/ci/lint'), params: { content: yaml_content }

          expect(response).to have_gitlab_http_status(:ok)
          expect(json_response['status']).to eq('invalid')
          expect(json_response['errors']).to eq(['Invalid configuration format'])
        end

        it 'outputs expanded yaml content' do
          post api('/ci/lint'), params: { content: yaml_content, include_merged_yaml: true }

          expect(response).to have_gitlab_http_status(:ok)
          expect(json_response).to have_key('merged_config')
        end
      end

      context 'with invalid configuration' do
        let(:yaml_content) { '{ image: "ruby:2.7",  services: ["postgres"] }' }

        it 'responds with errors about invalid configuration' do
          post api('/ci/lint'), params: { content: yaml_content }

          expect(response).to have_gitlab_http_status(:ok)
          expect(json_response['status']).to eq('invalid')
          expect(json_response['errors']).to eq(['jobs config should contain at least one visible job'])
        end

        it 'outputs expanded yaml content' do
          post api('/ci/lint'), params: { content: yaml_content, include_merged_yaml: true }

          expect(response).to have_gitlab_http_status(:ok)
          expect(json_response).to have_key('merged_config')
        end
      end
    end

    context 'without the content parameter' do
      it 'responds with validation error about missing content' do
        post api('/ci/lint')

        expect(response).to have_gitlab_http_status(:bad_request)
        expect(json_response['error']).to eq('content is missing')
      end
    end
  end
end
