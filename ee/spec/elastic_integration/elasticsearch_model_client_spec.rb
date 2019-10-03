# frozen_string_literal: true

require 'spec_helper'

# This module is monkey-patched in config/initializers/elastic_client_setup.rb
describe 'Monkey-patches to ::Elasticsearch::Model::Client', :elastic_stub do
  before do
    Gitlab::Elastic::Client.cached_clients.clear
    Gitlab::Elastic::Client.cached_configs.clear
  end

  def expect_build_client
    expect(Gitlab::Elastic::Client).to receive(:build).and_call_original
  end

  it 'reuses the same client instance for all models' do
    expect_build_client.with(current_es_index.connection_config).once

    client = Project.__elasticsearch__.client

    [Project, Issue, Snippet, Issue, Snippet, Project].each do |klass|
      expect(klass.__elasticsearch__.client).to be(client)
    end
  end

  context 'with multiple indices' do
    let(:index2) { create(:elasticsearch_index, urls: ['http://localhost:9202']) }
    let(:index3) { create(:elasticsearch_index, urls: ['http://localhost:9203']) }

    it 'reuses the same client instance for each index' do
      expect_build_client.with(current_es_index.connection_config).once.ordered
      expect_build_client.with(index2.connection_config).once.ordered
      expect_build_client.with(index3.connection_config).once.ordered

      client1 = Project.__elasticsearch__.client
      client2 = Project.__elasticsearch__.version(index2).client
      client3 = Project.__elasticsearch__.version(index3).client

      expect(client1).not_to be(client2)
      expect(client2).not_to be(client3)

      [Project, Issue, Snippet].each do |klass|
        expect(klass.__elasticsearch__.client).to be(client1)
        expect(klass.__elasticsearch__.version(index2).client).to be(client2)
        expect(klass.__elasticsearch__.version(index3).client).to be(client3)
      end
    end

    it 'creates a new client instance when the index configuration changes' do
      expect_build_client.with(index2.connection_config).once.ordered

      old_client = Project.__elasticsearch__.version(index2).client
      index2.update!(urls: ['http://localhost:9209'])

      expect_build_client.with(index2.connection_config).once.ordered

      new_client = Project.__elasticsearch__.version(index2).client

      expect(new_client).not_to be(old_client)
      expect(Project.__elasticsearch__.version(index2).client).to be(new_client)
    end
  end
end
