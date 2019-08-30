# frozen_string_literal: true

require 'spec_helper'
require Rails.root.join('db', 'migrate', '20191120115531_fill_elasticsearch_indices')

describe FillElasticsearchIndices, :migration do
  let(:migration) { described_class.new }
  let(:urls) { %w{http://localhost:9200 http://localhost:9201} }
  let(:application_settings) { described_class::ApplicationSetting }
  let(:elasticsearch_indices) { described_class::ElasticsearchIndex }

  let(:application_setting_attributes) do
    {
      elasticsearch_url:                   urls.join(','),
      elasticsearch_aws:                   true,
      elasticsearch_shards:                52,
      elasticsearch_replicas:              28,
      elasticsearch_aws_region:            'us-east-2',
      elasticsearch_aws_access_key:        'foo',
      elasticsearch_aws_secret_access_key: 'bar'
    }
  end

  let(:index_imported_attributes) do
    {
      urls:                  urls,
      aws:                   true,
      shards:                52,
      replicas:              28,
      aws_region:            'us-east-2',
      aws_access_key:        'foo',
      aws_secret_access_key: 'bar'
    }
  end

  let(:index_new_attributes) do
    {
      name:          'gitlab-production',
      friendly_name: 'Gitlab Production',
      version:       'V12p1'
    }
  end

  let(:index_existing_attributes) do
    index_imported_attributes.merge(index_new_attributes)
  end

  before do
    allow(License).to receive(:feature_available?).and_call_original
    allow(License).to receive(:feature_available?).with(:elastic_search).and_return(true)
  end

  describe '#up' do
    let(:application_setting) { application_settings.first }

    context 'when elasticsearch_indexing is true but elasticsearch_search is false' do
      before do
        application_settings.create!(
          application_setting_attributes.merge(elasticsearch_indexing: true, elasticsearch_search: false)
        )
      end

      it 'creates new index, but does not set association' do
        expect do
          migration.up
        end.to change { elasticsearch_indices.count }.from(0).to(1)

        index = elasticsearch_indices.first

        expect(index).to have_attributes(index_imported_attributes)
        expect(index).to have_attributes(index_new_attributes)

        expect(application_setting.elasticsearch_read_index_id).to be_nil
      end
    end

    context 'when elasticsearch_indexing is true and elasticsearch_search is true' do
      before do
        application_settings.create!(
          application_setting_attributes.merge(elasticsearch_indexing: true, elasticsearch_search: true)
        )
      end

      it 'creates new index and sets association' do
        expect do
          migration.up
        end.to change { elasticsearch_indices.count }.from(0).to(1)

        index = elasticsearch_indices.first

        expect(index).to have_attributes(index_imported_attributes)
        expect(index).to have_attributes(index_new_attributes)

        expect(application_setting.elasticsearch_read_index_id).to eq(index.id)
      end
    end

    context 'when elasticsearch_indexing is false' do
      before do
        application_settings.create!(
          application_setting_attributes.merge(elasticsearch_indexing: false)
        )
      end

      it 'does nothing' do
        migration.up

        expect(elasticsearch_indices.count).to eq(0)
      end
    end

    context 'when application_settings are absent' do
      it 'does nothing' do
        migration.up

        expect(elasticsearch_indices.count).to eq(0)
      end
    end
  end

  describe '#down' do
    shared_examples 'copying settings back to application_settings' do
      let!(:index) { elasticsearch_indices.create!(index_existing_attributes) }
      let!(:application_setting) { application_settings.create!(elasticsearch_indexing: elasticsearch_indexing) }

      it 'copies settings back to application_settings' do
        migration.down
        application_setting.reload

        expect(application_setting).to have_attributes(
          application_setting_attributes.merge(
            elasticsearch_url: urls,
            elasticsearch_indexing: elasticsearch_indexing
          )
        )

        expect(application_setting.elasticsearch_indexing?).to eq(elasticsearch_indexing)
        expect(application_setting.elasticsearch_read_index_id).to be_nil
      end
    end

    context 'when elasticsearch_indexing is true' do
      it_behaves_like 'copying settings back to application_settings' do
        let(:elasticsearch_indexing) { true }
      end
    end

    context 'when elasticsearch_indexing is false' do
      it_behaves_like 'copying settings back to application_settings' do
        let(:elasticsearch_indexing) { false }
      end
    end

    context 'when application_settings are absent' do
      let!(:index) { elasticsearch_indices.create!(index_existing_attributes) }

      it 'does nothing' do
        migration.down

        expect(application_settings.count).to eq(0)
      end
    end
  end
end
