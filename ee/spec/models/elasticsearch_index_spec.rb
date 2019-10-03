# frozen_string_literal: true

require 'spec_helper'

describe ElasticsearchIndex do
  subject { create(:elasticsearch_index) }

  describe 'validations' do
    it { is_expected.to allow_value(10).for(:shards) }
    it { is_expected.to allow_value(10).for(:replicas) }

    [nil, 0, 1.1, -1].each do |value|
      it { is_expected.not_to allow_value(value).for(:shards) }
      it { is_expected.not_to allow_value(value).for(:replicas) }
    end
  end

  describe 'encrypted attributes' do
    subject { described_class.encrypted_attributes.keys }

    it { is_expected.to contain_exactly(:aws_secret_access_key) }
  end

  describe '#urls' do
    it 'presents a single URL as a one-element array' do
      subject.urls_as_csv = 'http://example.com'

      expect(subject.urls).to eq(%w[http://example.com])
      expect(subject.urls_as_csv).to eq('http://example.com')
    end

    it 'presents multiple URLs as a many-element array' do
      subject.urls_as_csv = 'http://example.com,https://invalid.invalid:9200'

      expect(subject.urls).to eq(%w[http://example.com https://invalid.invalid:9200])
      expect(subject.urls_as_csv).to eq('http://example.com,https://invalid.invalid:9200')
    end

    it 'strips whitespace from around URLs' do
      subject.urls_as_csv = ' http://example.com, https://invalid.invalid:9200 '

      expect(subject.urls).to eq(%w[http://example.com https://invalid.invalid:9200])
      expect(subject.urls_as_csv).to eq('http://example.com,https://invalid.invalid:9200')
    end

    it 'strips trailing slashes from URLs' do
      subject.urls_as_csv = 'http://example.com/, https://example.com:9200/, https://example.com:9200/prefix//'

      expect(subject.urls).to eq(%w[http://example.com https://example.com:9200 https://example.com:9200/prefix])
      expect(subject.urls_as_csv).to eq('http://example.com,https://example.com:9200,https://example.com:9200/prefix')
    end
  end

  describe '#connection_config' do
    it 'places all connection configuration values into a hash' do
      subject.update!(
        urls: %w{http://example.com:9200},
        aws: false,
        aws_region: 'test-region',
        aws_access_key: 'test-access-key',
        aws_secret_access_key: 'test-secret-access-key'
      )

      expect(subject.connection_config).to eq(
        urls: %w{http://example.com:9200},
        aws: false,
        aws_region: 'test-region',
        aws_access_key: 'test-access-key',
        aws_secret_access_key: 'test-secret-access-key'
      )
    end
  end

  describe '#client' do
    it 'delegates to Gitlab::Elastic::Client' do
      client = double

      expect(Gitlab::Elastic::Client).to receive(:cached).with(subject).and_return(client)
      expect(subject.client).to be(client)
    end
  end
end
