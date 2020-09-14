# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Admin::ElasticsearchController do
  let(:admin) { create(:admin) }

  describe 'POST #enqueue_index' do
    before do
      sign_in(admin)
    end

    it 'starts indexing' do
      expect(Gitlab::Elastic::Helper.default).to(receive(:index_exists?)).and_return(true)
      expect_next_instance_of(::Elastic::IndexProjectsService) do |service|
        expect(service).to receive(:execute)
      end

      post :enqueue_index

      expect(controller).to set_flash[:notice].to include('/admin/sidekiq/queues/elastic_commit_indexer')
      expect(response).to redirect_to general_admin_application_settings_path(anchor: 'js-elasticsearch-settings')
    end

    context 'without an index' do
      before do
        allow(Gitlab::Elastic::Helper.default).to(receive(:index_exists?)).and_return(false)
      end

      it 'does nothing and returns 404' do
        expect(::Elastic::IndexProjectsService).not_to receive(:new)

        post :enqueue_index

        expect(controller).to set_flash[:warning].to include('create an index before enabling indexing')
        expect(response).to redirect_to general_admin_application_settings_path(anchor: 'js-elasticsearch-settings')
      end
    end
  end

  describe 'POST #trigger_reindexing' do
    before do
      sign_in(admin)
    end

    it 'creates a reindexing task' do
      expect(Elastic::ReindexingTask).to receive(:create!)

      post :trigger_reindexing

      expect(controller).to set_flash[:notice].to include('reindexing triggered')
      expect(response).to redirect_to general_admin_application_settings_path(anchor: 'js-elasticsearch-settings')
    end

    it 'does not create a reindexing task if there is another one' do
      allow(Elastic::ReindexingTask).to receive(:current).and_return(build(:elastic_reindexing_task))
      expect(Elastic::ReindexingTask).not_to receive(:create!)

      post :trigger_reindexing

      expect(controller).to set_flash[:warning].to include('already in progress')
      expect(response).to redirect_to general_admin_application_settings_path(anchor: 'js-elasticsearch-settings')
    end
  end

  describe 'POST #cancel_index_deletion' do
    before do
      sign_in(admin)
    end

    let(:task) { create(:elastic_reindexing_task, state: :success, delete_original_index_at: Time.current) }

    it 'sets delete_original_index_at to nil' do
      post :cancel_index_deletion, params: { task_id: task.id }

      expect(task.reload.delete_original_index_at).to be_nil
      expect(controller).to set_flash[:notice].to include('deletion is canceled')
      expect(response).to redirect_to general_admin_application_settings_path(anchor: 'js-elasticsearch-settings')
    end
  end
end
