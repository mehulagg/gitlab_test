# frozen_string_literal: true

require 'spec_helper'

describe Elastic::CreateIndexService do
  let(:user) { build(:admin) }
  let(:params) { attributes_for(:elasticsearch_index) }

  subject { described_class.new(user, params) }

  before do
    allow(Gitlab::Elastic::Helper).to receive(:create_empty_index)
  end

  it 'creates the DB record and ES index' do
    index = subject.execute

    expect(index).to be_persisted
    expect(Gitlab::Elastic::Helper).to have_received(:create_empty_index).with(index)
  end

  context 'when user is not an admin' do
    let(:user) { build(:user) }

    it 'raises an exception' do
      expect do
        subject.execute
      end.to raise_error(Gitlab::Access::AccessDeniedError)
    end
  end

  context 'when params are invalid' do
    let(:params) { {} }

    it 'does not create the DB record or ES index' do
      index = subject.execute

      expect(index).not_to be_persisted
      expect(Gitlab::Elastic::Helper).not_to have_received(:create_empty_index)
    end
  end

  context 'when the ES index cannot be created' do
    before do
      expect(Gitlab::Elastic::Helper).to receive(:create_empty_index) do
        raise Faraday::ConnectionFailed, 'details'
      end
    end

    it 'does not create the DB record and returns an error' do
      index = subject.execute

      expect(index).not_to be_persisted
      expect(index.errors[:base]).to contain_exactly(
        "Error while creating Elasticsearch index, please check your configuration (Faraday::ConnectionFailed: details)"
      )
    end
  end
end
