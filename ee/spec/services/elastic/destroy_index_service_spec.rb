# frozen_string_literal: true

require 'spec_helper'

describe Elastic::DestroyIndexService do
  let(:user) { build(:admin) }
  let(:index) { create(:elasticsearch_index) }

  subject { described_class.new(user, index) }

  before do
    allow(Gitlab::Elastic::Helper).to receive(:delete_index)
  end

  it 'destroys the DB record and ES index' do
    index = subject.execute

    expect(index).to be_destroyed
    expect(Gitlab::Elastic::Helper).to have_received(:delete_index).with(index)
  end

  context 'when user is not an admin' do
    let(:user) { build(:user) }

    it 'raises an exception' do
      expect do
        subject.execute
      end.to raise_error(Gitlab::Access::AccessDeniedError)
    end
  end

  context 'when index is the active search source' do
    before do
      stub_ee_application_setting(elasticsearch_read_index_id: index.id)
    end

    it 'does not delete the DB record or ES index and returns an error' do
      index = subject.execute

      expect(index).not_to be_destroyed
      expect(index.errors[:base]).to contain_exactly("Can't delete the active search source")
      expect(Gitlab::Elastic::Helper).not_to have_received(:delete_index)
    end
  end

  context 'when the ES index cannot be deleted' do
    before do
      expect(Gitlab::Elastic::Helper).to receive(:delete_index) do
        raise Faraday::ConnectionFailed, 'details'
      end
    end

    it 'does not destroy the DB record and returns an error' do
      index = subject.execute

      expect(index).not_to be_destroyed
      expect(index.errors[:base]).to contain_exactly(
        "Error while deleting Elasticsearch index, please check your configuration (Faraday::ConnectionFailed: details)"
      )
    end
  end
end
