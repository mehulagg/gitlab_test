# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::ReactiveCacheSetCache, :clean_gitlab_redis_cache do
  let_it_be(:project) { create(:project) }
  let(:cache_prefix) { 'cache_prefix' }
  let(:expires_in) { 10.minutes }
  let(:cache) { described_class.new(cache_prefix, expires_in: expires_in) }

  describe '#cache_key' do
    subject { cache.cache_key }

    it 'includes the suffix' do
      expect(subject).to eq "#{cache_prefix}:set"
    end
  end

  describe '#values' do
    subject { cache.values }

    it { is_expected.to be_empty }

    context 'after item added' do
      before do
        cache.write('test_item')
      end

      it { is_expected.to contain_exactly('test_item') }
    end
  end

  describe '#write' do
    it 'expires the given key from the cache' do
      cache.write('test_item')

      expect(cache.values).to contain_exactly('test_item')
    end
  end

  describe '#clear_cache!' do
    it 'deletes the cached items' do
      cache.write('test_item')

      expect(cache.values).to contain_exactly('test_item')
      expect(cache.clear_cache!).to eq(1)

      expect(cache.values).to be_empty
    end
  end

  describe '#include?' do
    subject { cache.include?('test_item') }

    it { is_expected.to be(false) }

    context 'item added' do
      before do
        cache.write('test_item')
      end

      it { is_expected.to be(true) }
    end
  end
end
