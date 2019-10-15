# frozen_string_literal: true

require 'spec_helper'

describe ElasticsearchIndex do
  subject { create(:elasticsearch_index) }

  describe 'validations' do
    let(:url) { FactoryBot.generate(:url) }

    it { is_expected.to validate_presence_of(:friendly_name) }
    it { is_expected.to validate_presence_of(:shards) }
    it { is_expected.to validate_presence_of(:replicas) }

    it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
    it { is_expected.to validate_uniqueness_of(:friendly_name).case_insensitive }

    it { is_expected.to validate_numericality_of(:shards).only_integer.is_greater_than(0) }
    it { is_expected.to validate_numericality_of(:replicas).only_integer.is_greater_than(0) }

    # validate_length_of doesn't support arrays
    # https://github.com/thoughtbot/shoulda-matchers/issues/1064
    it { is_expected.to allow_value([url]).for(:urls) }
    it { is_expected.not_to allow_value([]).for(:urls).with_message("can't be blank") }
    it { is_expected.not_to allow_value([url] * 1001).for(:urls).with_message('is too long (maximum is 1000 entries)') }

    # validate_addressable_urls
    it { is_expected.not_to allow_value(['']).for(:urls).with_message('must be a valid URL') }
    it { is_expected.not_to allow_value(['invalid']).for(:urls).with_message('is blocked: Only allowed schemes are http, https') }
    it { is_expected.not_to allow_value(['http://']).for(:urls).with_message('is blocked: URI is invalid') }

    context 'with AWS disabled' do
      it { is_expected.not_to validate_presence_of(:aws_region) }
    end

    context 'with AWS enabled' do
      subject { build(:elasticsearch_index, :aws) }

      it { is_expected.to validate_presence_of(:aws_region).with_message("can't be blank when using AWS hosted Elasticsearch") }
    end
  end

  describe 'read-only attributes' do
    subject { described_class.readonly_attributes }

    it { is_expected.to contain_exactly('name', 'version', 'shards', 'replicas') }
  end

  describe 'encrypted attributes' do
    subject { described_class.encrypted_attributes.keys }

    it { is_expected.to contain_exactly(:aws_secret_access_key) }
  end

  describe '#urls=' do
    it 'splits a comma-separated string' do
      subject.urls = 'http://localhost, http://example.com'

      expect(subject.urls).to eq(['http://localhost', 'http://example.com'])
    end

    it 'strips whitespace around URLs' do
      subject.urls = [' http://localhost ', ' http://example.com ']

      expect(subject.urls).to eq(['http://localhost', 'http://example.com'])
    end

    it 'strips trailing slashes from URLs' do
      subject.urls = ['http://localhost/', 'http://example.com//']

      expect(subject.urls).to eq(['http://localhost', 'http://example.com'])
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

  describe '#set_version' do
    subject { build(:elasticsearch_index) }

    it 'automatically sets the version' do
      expect(subject.version).to be_nil
      expect(subject).to be_valid
      expect(subject.version).to eq('V12p1')
    end
  end

  describe '#build_name' do
    subject { build(:elasticsearch_index) }

    it 'automatically generates the name' do
      expect(subject.name).to be_nil
      expect(subject).to be_valid
      expect(subject.name).to match(/^gitlab-test-v12p1-\h{8}$/)
    end

    it 'does not override a custom name' do
      expect(subject.name).to be_nil

      subject.name = 'my-custom-index'

      expect(subject).to be_valid
      expect(subject.name).to eq('my-custom-index')
    end
  end
end
