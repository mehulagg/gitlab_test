# frozen_string_literal: true

require 'spec_helper'

describe Feature, stub_feature_flags: false do
  before do
    # reset Flipper AR-engine
    Feature.reset
  end

  describe '.get' do
    let(:feature) { double(:feature) }
    let(:key) { 'my_feature' }

    it 'returns the Flipper feature' do
      expect_any_instance_of(Flipper::DSL).to receive(:feature).with(key)
        .and_return(feature)

      expect(described_class.get(key)).to be(feature)
    end
  end

  describe '.persisted_names' do
    context 'when FF_LEGACY_PERSISTED_NAMES=false' do
      before do
        stub_env('FF_LEGACY_PERSISTED_NAMES', 'false')
      end

      it 'returns the names of the persisted features' do
        Feature.enable('foo')

        expect(described_class.persisted_names).to contain_exactly('foo')
      end

      it 'returns an empty Array when no features are presisted' do
        expect(described_class.persisted_names).to be_empty
      end

      it 'caches the feature names when request store is active',
       :request_store, :use_clean_rails_memory_store_caching do
        Feature.enable('foo')

        expect(Gitlab::ProcessMemoryCache.cache_backend)
          .to receive(:fetch)
          .once
          .with('flipper/v1/features', expires_in: 1.minute)
          .and_call_original

        2.times do
          expect(described_class.persisted_names).to contain_exactly('foo')
        end
      end
    end

    context 'when FF_LEGACY_PERSISTED_NAMES=true' do
      before do
        stub_env('FF_LEGACY_PERSISTED_NAMES', 'true')
      end

      it 'returns the names of the persisted features' do
        Feature.enable('foo')

        expect(described_class.persisted_names).to contain_exactly('foo')
      end

      it 'returns an empty Array when no features are presisted' do
        expect(described_class.persisted_names).to be_empty
      end

      it 'caches the feature names when request store is active',
       :request_store, :use_clean_rails_memory_store_caching do
        Feature.enable('foo')

        expect(Gitlab::ProcessMemoryCache.cache_backend)
          .to receive(:fetch)
          .once
          .with('flipper:persisted_names', expires_in: 1.minute)
          .and_call_original

        2.times do
          expect(described_class.persisted_names).to contain_exactly('foo')
        end
      end
    end

    it 'fetches all flags once in a single query', :request_store do
      Feature.enable('foo1')
      Feature.enable('foo2')

      queries = ActiveRecord::QueryRecorder.new(skip_cached: false) do
        expect(described_class.persisted_names).to contain_exactly('foo1', 'foo2')

        RequestStore.clear!

        expect(described_class.persisted_names).to contain_exactly('foo1', 'foo2')
      end

      expect(queries.count).to eq(1)
    end
  end

  describe '.persisted_name?' do
    context 'when the feature is persisted' do
      it 'returns true when feature name is a string' do
        Feature.enable('foo')

        expect(described_class.persisted_name?('foo')).to eq(true)
      end

      it 'returns true when feature name is a symbol' do
        Feature.enable('foo')

        expect(described_class.persisted_name?(:foo)).to eq(true)
      end
    end

    context 'when the feature is not persisted' do
      it 'returns false when feature name is a string' do
        expect(described_class.persisted_name?('foo')).to eq(false)
      end

      it 'returns false when feature name is a symbol' do
        expect(described_class.persisted_name?(:bar)).to eq(false)
      end
    end
  end

  describe '.all' do
    let(:features) { Set.new }

    it 'returns the Flipper features as an array' do
      expect_any_instance_of(Flipper::DSL).to receive(:features)
        .and_return(features)

      expect(described_class.all).to eq(features.to_a)
    end
  end

  describe '.flipper' do
    context 'when request store is inactive' do
      it 'memoizes the Flipper instance' do
        expect(Flipper).to receive(:new).once.and_call_original

        2.times do
          described_class.send(:flipper)
        end
      end
    end

    context 'when request store is active', :request_store do
      it 'memoizes the Flipper instance' do
        expect(Flipper).to receive(:new).once.and_call_original

        described_class.send(:flipper)
        described_class.instance_variable_set(:@flipper, nil)
        described_class.send(:flipper)
      end
    end
  end

  describe '.enabled?' do
    it 'returns false for undefined feature' do
      expect(described_class.enabled?(:some_random_feature_flag)).to be_falsey
    end

    it 'returns true for undefined feature with default_enabled' do
      expect(described_class.enabled?(:some_random_feature_flag, default_enabled: true)).to be_truthy
    end

    it 'returns false for existing disabled feature in the database' do
      described_class.disable(:disabled_feature_flag)

      expect(described_class.enabled?(:disabled_feature_flag)).to be_falsey
    end

    it 'returns true for existing enabled feature in the database' do
      described_class.enable(:enabled_feature_flag)

      expect(described_class.enabled?(:enabled_feature_flag)).to be_truthy
    end

    it { expect(described_class.send(:l1_cache_backend)).to eq(Gitlab::ProcessMemoryCache.cache_backend) }
    it { expect(described_class.send(:l2_cache_backend)).to eq(Rails.cache) }

    it 'caches the status in L1 and L2 caches',
       :request_store, :use_clean_rails_memory_store_caching do
      described_class.enable(:enabled_feature_flag)
      flipper_key = "flipper/v1/feature/enabled_feature_flag"

      expect(described_class.send(:l2_cache_backend))
        .to receive(:fetch)
        .once
        .with(flipper_key, expires_in: 1.hour)
        .and_call_original

      expect(described_class.send(:l1_cache_backend))
        .to receive(:fetch)
        .once
        .with(flipper_key, expires_in: 1.minute)
        .and_call_original

      2.times do
        expect(described_class.enabled?(:enabled_feature_flag)).to be_truthy
      end
    end

    it 'returns the default value when the database does not exist' do
      fake_default = double('fake default')
      expect(ActiveRecord::Base).to receive(:connection) { raise ActiveRecord::NoDatabaseError, "No database" }

      expect(described_class.enabled?(:a_feature, default_enabled: fake_default)).to eq(fake_default)
    end

    context 'cached feature flag', :request_store do
      let(:flag) { :some_feature_flag }

      before do
        described_class.send(:flipper).memoize = false
        described_class.enabled?(flag)
      end

      it 'caches the status in L1 cache for the first minute' do
        expect do
          expect(described_class.send(:l1_cache_backend)).to receive(:fetch).once.and_call_original
          expect(described_class.send(:l2_cache_backend)).not_to receive(:fetch)
          expect(described_class.enabled?(flag)).to be_truthy
        end.not_to exceed_query_limit(0)
      end

      it 'caches the status in L2 cache after 2 minutes' do
        Timecop.travel 2.minutes do
          expect do
            expect(described_class.send(:l1_cache_backend)).to receive(:fetch).once.and_call_original
            expect(described_class.send(:l2_cache_backend)).to receive(:fetch).once.and_call_original
            expect(described_class.enabled?(flag)).to be_truthy
          end.not_to exceed_query_limit(0)
        end
      end

      it 'fetches the status after an hour' do
        Timecop.travel 61.minutes do
          expect do
            expect(described_class.send(:l1_cache_backend)).to receive(:fetch).once.and_call_original
            expect(described_class.send(:l2_cache_backend)).to receive(:fetch).once.and_call_original
            expect(described_class.enabled?(flag)).to be_truthy
          end.not_to exceed_query_limit(1)
        end
      end
    end

    context 'with an individual actor' do
      let(:actor) { stub_feature_flag_gate('CustomActor:5') }
      let(:another_actor) { stub_feature_flag_gate('CustomActor:10') }

      before do
        described_class.enable(:enabled_feature_flag, actor)
      end

      it 'returns true when same actor is informed' do
        expect(described_class.enabled?(:enabled_feature_flag, actor)).to be_truthy
      end

      it 'returns false when different actor is informed' do
        expect(described_class.enabled?(:enabled_feature_flag, another_actor)).to be_falsey
      end

      it 'returns false when no actor is informed' do
        expect(described_class.enabled?(:enabled_feature_flag)).to be_falsey
      end
    end
  end

  describe '.disable?' do
    it 'returns true for undefined feature' do
      expect(described_class.disabled?(:some_random_feature_flag)).to be_truthy
    end

    it 'returns false for undefined feature with default_enabled' do
      expect(described_class.disabled?(:some_random_feature_flag, default_enabled: true)).to be_falsey
    end

    it 'returns true for existing disabled feature in the database' do
      described_class.disable(:disabled_feature_flag)

      expect(described_class.disabled?(:disabled_feature_flag)).to be_truthy
    end

    it 'returns false for existing enabled feature in the database' do
      described_class.enable(:enabled_feature_flag)

      expect(described_class.disabled?(:enabled_feature_flag)).to be_falsey
    end
  end

  describe '.remove' do
    context 'for a non-persisted feature' do
      it 'returns nil' do
        expect(described_class.remove(:non_persisted_feature_flag)).to be_nil
      end
    end

    context 'for a persisted feature' do
      it 'returns true' do
        described_class.enable(:persisted_feature_flag)

        expect(described_class.remove(:persisted_feature_flag)).to be_truthy
      end
    end
  end

  describe Feature::Target do
    describe '#targets' do
      let(:project) { create(:project) }
      let(:group) { create(:group) }
      let(:user_name) { project.owner.username }

      subject { described_class.new(user: user_name, project: project.full_path, group: group.full_path) }

      it 'returns all found targets' do
        expect(subject.targets).to be_an(Array)
        expect(subject.targets).to eq([project.owner, project, group])
      end
    end
  end
end
