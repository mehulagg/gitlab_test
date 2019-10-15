# frozen_string_literal: true

require 'spec_helper'

describe API::ElasticsearchIndices do
  let(:admin) { create(:admin) }
  let(:user) { create(:user) }
  let(:active_index) { create(:elasticsearch_index) }
  let(:inactive_index) { create(:elasticsearch_index, name: 'inactive', urls: ['http://localhost:9200', 'http://localhost:9201']) }
  let(:current_settings) { create(:application_setting, elasticsearch_read_index: active_index) }

  before do
    stub_env('IN_MEMORY_APPLICATION_SETTINGS', 'false')
  end

  describe 'GET /elasticsearch_indices' do
    before do
      active_index
      inactive_index
      current_settings
    end

    it 'returns all indices' do
      get api('/elasticsearch_indices', admin)

      expect(response).to have_gitlab_http_status(200)
      expect(json_response).to be_an Array
      expect(json_response.size).to be(2)

      expect(json_response[0]['id']).to eq(active_index.id)
      expect(json_response[0]['urls']).to eq(active_index.urls.join(', '))
      expect(json_response[0]['active_search_source']).to be(true)

      expect(json_response[1]['id']).to eq(inactive_index.id)
      expect(json_response[1]['urls']).to eq(inactive_index.urls.join(', '))
      expect(json_response[1]['active_search_source']).to be(false)
    end

    it_behaves_like '403 response' do
      let(:request) { get api('/elasticsearch_indices', user) }
    end
  end

  describe 'GET /elasticsearch_indices/:id' do
    before do
      active_index
      current_settings
    end

    it 'returns a single index' do
      get api("/elasticsearch_indices/#{active_index.id}", admin)

      expect(response).to have_gitlab_http_status(200)
      expect(json_response).to be_a Hash
      expect(json_response['id']).to eq(active_index.id)
      expect(json_response['active_search_source']).to be(true)
    end

    it_behaves_like '403 response' do
      let(:request) { get api("/elasticsearch_indices/#{active_index.id}", user) }
    end

    it_behaves_like '404 response' do
      let(:request) { get api("/elasticsearch_indices/99999", admin) }
    end
  end

  describe 'POST /elasticsearch_indices' do
    let(:attributes) { attributes_for(:elasticsearch_index) }
    let(:params) { attributes.merge(urls: attributes[:urls].join(', ')) }

    it 'creates a new index' do
      attributes.merge!(friendly_name: 'new', shards: 23)

      expect(Gitlab::Elastic::Helper).to receive(:create_empty_index)
        .with(having_attributes(attributes))

      expect_request_with_status(201) do
        post api('/elasticsearch_indices', admin), params: params
      end.to change { ElasticsearchIndex.count }.by(1)

      expect(json_response).to be_a(Hash)
      expect(json_response['friendly_name']).to eq('new')
      expect(json_response['shards']).to eq(23)
    end

    it 'returns errors if index creation fails' do
      attributes.merge!(friendly_name: '', shards: 0)

      expect(Gitlab::Elastic::Helper).not_to receive(:create_empty_index)

      expect_request_with_status(400) do
        post api('/elasticsearch_indices', admin), params: params
      end.not_to change { ElasticsearchIndex.count }

      expect(json_response).to be_a(Hash)
      expect(json_response['message'].keys).to contain_exactly('friendly_name', 'shards')
    end

    it_behaves_like '403 response' do
      let(:request) { post api('/elasticsearch_indices', user) }
    end
  end

  describe 'PUT /elasticsearch_indices/:id' do
    before do
      active_index
    end

    it 'updates an existing index' do
      expect_request_with_status(200) do
        put api("/elasticsearch_indices/#{active_index.id}", admin), params: { friendly_name: 'new', shards: 23 }
      end.to change { active_index.reload.friendly_name }.to('new')

      expect(json_response).to be_a(Hash)
      expect(json_response['id']).to eq(active_index.id)
      expect(json_response['friendly_name']).to eq('new')

      expect(json_response['shards']).not_to eq(23)
    end

    it_behaves_like '403 response' do
      let(:request) { put api("/elasticsearch_indices/#{active_index.id}", user) }
    end

    it_behaves_like '404 response' do
      let(:request) { put api('/elasticsearch_indices/99999', admin) }
    end
  end

  describe 'DELETE /elasticsearch_indices/:id' do
    it 'deletes an existing index' do
      expect(Gitlab::Elastic::Helper).to receive(:delete_index)
        .with(inactive_index)

      expect_request_with_status(204) do
        delete api("/elasticsearch_indices/#{inactive_index.id}", admin)
      end.to change { ElasticsearchIndex.count }.by(-1)
    end

    it 'returns errors if index deletion fails' do
      current_settings

      expect(Gitlab::Elastic::Helper).not_to receive(:delete_index)

      expect_request_with_status(400) do
        delete api("/elasticsearch_indices/#{active_index.id}", admin)
      end.not_to change { ElasticsearchIndex.count }

      expect(json_response).to be_a(Hash)
      expect(json_response['message']).to eq(
        'base' => ["Can't delete the active search source"]
      )
    end

    xcontext 'when specifying a new search source' do
      it 'switches the active search source' do
        expect_request_with_status(204) do
          delete api("/elasticsearch_indices/#{active_index.id}", admin), params: { search_source_id: inactive_index.id }
        end.to change { ElasticsearchIndex.count }.by(-1)

        expect(current_settings.reload.elasticsearch_read_index).to eq(inactive_index)
      end
    end

    it_behaves_like '403 response' do
      let(:request) { delete api("/elasticsearch_indices/#{inactive_index.id}", user) }
    end

    it_behaves_like '404 response' do
      let(:request) { delete api('/elasticsearch_indices/99999', admin) }
    end
  end

  describe 'POST mark_active_search_source' do
    before do
      active_index
      inactive_index
      current_settings
    end

    it 'changes the active search source' do
      expect_request_with_status(204) do
        post api("/elasticsearch_indices/mark_active_search_source/#{inactive_index.id}", admin)
      end.to change { current_settings.reload.elasticsearch_read_index }.from(active_index).to(inactive_index)
    end

    it_behaves_like '403 response' do
      let(:request) { post api("/elasticsearch_indices/mark_active_search_source/#{inactive_index.id}", user) }
    end

    it_behaves_like '404 response' do
      let(:request) { post api('/elasticsearch_indices/mark_active_search_source/99999', admin) }
    end
  end

  describe 'POST toggle_indexing' do
    before do
      current_settings
    end

    it 'changes indexing to the given value' do
      expect_request_with_status(204) do
        post api('/elasticsearch_indices/toggle_indexing', admin), params: { indexing: true }
      end.to change { current_settings.reload.elasticsearch_indexing }.from(false).to(true)
    end

    it_behaves_like '403 response' do
      let(:request) { post api('/elasticsearch_indices/toggle_indexing', user) }
    end
  end

  describe 'POST reindex' do
    it 'queues an indexing job' do
      expect_next_instance_of(Elastic::IndexProjectsService) do |service|
        expect(service).to receive(:execute)
      end

      current_settings.update!(elasticsearch_indexing: true)

      post api('/elasticsearch_indices/reindex', admin)

      expect(response).to have_gitlab_http_status(204)
    end

    it 'enables indexing if it was disabled' do
      expect_next_instance_of(Elastic::IndexProjectsService) do |service|
        expect(service).to receive(:execute)
      end

      current_settings.update!(elasticsearch_indexing: false)

      post api('/elasticsearch_indices/reindex', admin)

      expect(response).to have_gitlab_http_status(204)
      expect(current_settings.reload.elasticsearch_indexing).to be(true)
    end

    it_behaves_like '403 response' do
      let(:request) { post api('/elasticsearch_indices/reindex', user) }
    end
  end
end
