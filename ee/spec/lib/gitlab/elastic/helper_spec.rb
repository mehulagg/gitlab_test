# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Elastic::Helper do
  let(:index) { create(:elasticsearch_index) }
  let(:client) { index.client }

  def indices
    client.indices.get_aliases.keys.grep(/^gitlab-test-/)
  end

  after do
    # Reset any mocks
    allow(client.indices).to receive(:delete).and_call_original

    indices.each do |index|
      client.indices.delete(index: index)
    end
  end

  describe '.create_empty_index' do
    it 'creates a new index with all configured mappings and settings' do
      expected_mappings = Elastic::V12p1::Config.mappings.to_hash
      expected_settings = Elastic::V12p1::Config.settings.to_hash.deep_merge(
        index: {
          number_of_shards: index.shards,
          number_of_replicas: index.replicas
        }
      )

      # On CI we're running ES 5.6
      if Gitlab::VersionInfo.parse(client.info['version']['number']) < Gitlab::VersionInfo.new(6)
        expected_settings.deep_merge!(
          index: { mapping: { single_type: true } }
        )
      end

      expect(client.indices).to receive(:create).with(
        index: index.name,
        body: {
          mappings: expected_mappings,
          settings: expected_settings
        }
      ).and_call_original

      expect(indices).to eq([])

      subject.create_empty_index(index)

      expect(indices).to eq([index.name])

      # The JSON returned from ES has differences from the one we send it (order, certain keys),
      # so we only perform some sanity checks.
      mappings = client.indices.get_mapping.fetch(index.name).fetch('mappings')
      settings = client.indices.get_settings.fetch(index.name).fetch('settings')

      expected_mappings.deep_stringify_keys!
      expected_settings.deep_stringify_keys!

      # Verify all mapped properties are present
      expect(mappings['doc']['properties'].keys).to contain_exactly(
        *expected_mappings['doc']['properties'].keys)

      # Verify all mapped relations are present
      expect(mappings['doc']['properties']['join_field']['relations']['project']).to contain_exactly(
        *expected_mappings['doc']['properties']['join_field']['relations']['project'].map(&:to_s))

      # Verify all global settings are present
      extra_settings = %w[creation_date provided_name uuid version]
      expect(settings['index'].keys - extra_settings).to contain_exactly(
        *expected_settings['index'].keys)

      # Verify the index settings are present
      expect(settings['index']['number_of_shards']).to eq(index.shards.to_s)
      expect(settings['index']['number_of_replicas']).to eq(index.replicas.to_s)
    end

    it 'uses a custom setting for ES versions < 6' do
      expect(client).to receive(:info).and_return('version' => { 'number' => '5.6.1' })
      expect(client.indices).to receive(:create).with(
        index: index.name,
        body: hash_including(settings: hash_including(index: hash_including(mapping: { single_type: true })))
      )

      subject.create_empty_index(index)
    end

    it 'deletes the index first if it already exists' do
      subject.create_empty_index(index)

      expect(indices).to eq([index.name])
      expect(client.indices).to receive(:delete).with(index: index.name).and_call_original

      subject.create_empty_index(index)

      expect(indices).to eq([index.name])
    end
  end

  describe '.delete_index' do
    it 'deletes the index' do
      subject.create_empty_index(index)

      expect(indices).to eq([index.name])

      subject.delete_index(index)

      expect(indices).to eq([])
    end
  end

  describe '.refresh_index' do
    let(:index2) { create(:elasticsearch_index) }
    let(:client2) { index2.client }

    before do
      subject.create_empty_index(index)
      subject.create_empty_index(index2)

      stub_ee_application_setting(elasticsearch_read_index: index)
    end

    it 'forwards the call to all indices' do
      expect(client.indices).to receive(:refresh)
        .with(index: index.name)
        .once.ordered.and_call_original

      expect(client2.indices).to receive(:refresh)
        .with(index: index2.name)
        .once.ordered.and_call_original

      subject.refresh_index
    end
  end

  describe '.index_size' do
    before do
      subject.create_empty_index(index)
    end

    it 'returns the totals for the given index' do
      totals = subject.index_size(index)

      expect(totals.dig('docs', 'count')).to eq(0)
      expect(totals.dig('store', 'size_in_bytes')).to be > 0
    end
  end

  describe '.index_exists' do
    it 'returns correct values' do
      described_class.create_empty_index

      expect(described_class.index_exists?).to eq(true)

      described_class.delete_index

      expect(described_class.index_exists?).to eq(false)
    end
  end

  describe 'reindex_to_another_cluster' do
    it 'creates an empty index and triggers a reindex' do
      _version_check_request = stub_request(:get, 'http://newcluster.example.com:9200/')
        .to_return(status: 200, body: { version: { number: '7.5.1' } }.to_json)

      _index_exists_check = stub_request(:head, 'http://newcluster.example.com:9200/gitlab-test')
        .to_return(status: 404, body: +'')

      create_cluster_request = stub_request(:put, 'http://newcluster.example.com:9200/gitlab-test')
        .to_return(status: 200, body: +'')

      optimize_settings_for_write_request = stub_request(:put, 'http://newcluster.example.com:9200/gitlab-test/_settings')
        .with(body: { index: { number_of_replicas: 0, refresh_interval: "-1" } })
        .to_return(status: 200, body: +'')

      reindex_request = stub_request(:post, 'http://newcluster.example.com:9200/_reindex?wait_for_completion=false')
        .with(
          body: {
            source: {
              remote: {
                host: 'http://oldcluster.example.com:9200/',
                username: 'olduser',
                password: 'oldpass'
              },
              index: 'gitlab-test'
            },
            dest: {
              index: 'gitlab-test'
            }
          }).to_return(status: 200,
                       headers: { "Content-Type" => "application/json" },
                       body: { task: 'abc123' }.to_json)

      source_url = 'http://olduser:oldpass@oldcluster.example.com:9200/'
      dest_url = 'http://newcluster.example.com:9200/'

      task = Gitlab::Elastic::Helper.reindex_to_another_cluster(source_url, dest_url)
      expect(task).to eq('abc123')

      assert_requested create_cluster_request
      assert_requested optimize_settings_for_write_request
      assert_requested reindex_request
    end
  end
end
