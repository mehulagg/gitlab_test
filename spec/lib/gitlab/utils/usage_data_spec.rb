# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Utils::UsageData do
  describe '#count' do
    let(:relation) { double(:relation) }

    it 'returns the count when counting succeeds' do
      allow(relation).to receive(:count).and_return(1)

      expect(described_class.count(relation, batch: false)).to eq(1)
    end

    it 'returns the fallback value when counting fails' do
      stub_const("Gitlab::Utils::UsageData::FALLBACK", 15)
      allow(relation).to receive(:count).and_raise(ActiveRecord::StatementInvalid.new(''))

      expect(described_class.count(relation, batch: false)).to eq(15)
    end
  end

  describe '#distinct_count' do
    let(:relation) { double(:relation) }

    it 'returns the count when counting succeeds' do
      allow(relation).to receive(:distinct_count_by).and_return(1)

      expect(described_class.distinct_count(relation, batch: false)).to eq(1)
    end

    it 'returns the fallback value when counting fails' do
      stub_const("Gitlab::Utils::UsageData::FALLBACK", 15)
      allow(relation).to receive(:distinct_count_by).and_raise(ActiveRecord::StatementInvalid.new(''))

      expect(described_class.distinct_count(relation, batch: false)).to eq(15)
    end
  end

  describe '#alt_usage_data' do
    it 'returns the fallback when it gets an error' do
      expect(described_class.alt_usage_data { raise StandardError } ).to eq(-1)
    end

    it 'returns the evaluated block when give' do
      expect(described_class.alt_usage_data { Gitlab::CurrentSettings.uuid } ).to eq(Gitlab::CurrentSettings.uuid)
    end

    it 'returns the value when given' do
      expect(described_class.alt_usage_data(1)).to eq 1
    end
  end

  describe '#redis_usage_data' do
    context 'with block given' do
      it 'returns the fallback when it gets an error' do
        expect(described_class.redis_usage_data { raise ::Redis::CommandError } ).to eq(-1)
      end

      it 'returns the evaluated block when given' do
        expect(described_class.redis_usage_data { 1 }).to eq(1)
      end
    end

    context 'with counter given' do
      it 'returns the falback values for all counter keys when it gets an error' do
        allow(::Gitlab::UsageDataCounters::WikiPageCounter).to receive(:totals).and_raise(::Redis::CommandError)
        expect(described_class.redis_usage_data(::Gitlab::UsageDataCounters::WikiPageCounter)).to eql(::Gitlab::UsageDataCounters::WikiPageCounter.fallback_totals)
      end

      it 'returns the totals when couter is given' do
        allow(::Gitlab::UsageDataCounters::WikiPageCounter).to receive(:totals).and_return({ wiki_pages_create: 2 })
        expect(described_class.redis_usage_data(::Gitlab::UsageDataCounters::WikiPageCounter)).to eql({ wiki_pages_create: 2 })
      end
    end
  end

  describe '#with_prometheus_client' do
    shared_examples 'query data from Prometheus' do
      it 'yields a client instance and returns the block result' do
        result = described_class.with_prometheus_client { |client| client }

        expect(result).to be_an_instance_of(Gitlab::PrometheusClient)
      end
    end

    context 'when Prometheus is available from settings' do
      before do
        expect(Gitlab::Prometheus::Internal).to receive(:prometheus_enabled?).and_return(true)
        expect(Gitlab::Prometheus::Internal).to receive(:uri).and_return('http://prom:9090')
      end

      it_behaves_like 'query data from Prometheus'
    end

    context 'when Prometheus is available from Consul service discovery' do
      before do
        expect(Gitlab::Prometheus::Internal).to receive(:prometheus_enabled?).and_return(false)
        expect(Gitlab::Consul::Internal).to receive(:api_url).and_return('http://localhost:8500')
        expect(Gitlab::Consul::Internal).to receive(:discover_prometheus_uri).and_return('http://prom:9090')
      end

      it_behaves_like 'query data from Prometheus'
    end

    context 'when Prometheus is not available' do
      before do
        expect(Gitlab::Prometheus::Internal).to receive(:prometheus_enabled?).and_return(false)
        expect(Gitlab::Consul::Internal).to receive(:api_url).and_return(nil)
      end

      it 'returns nil by default' do
        result = described_class.with_prometheus_client { |client| client }

        expect(result).to be nil
      end

      it 'returns fallback if provided' do
        result = described_class.with_prometheus_client(fallback: []) { |client| client }

        expect(result).to eq([])
      end
    end
  end

  describe '#measure_duration' do
    it 'returns block result and execution duration' do
      allow(Process).to receive(:clock_gettime).and_return(1, 3)

      result, duration = described_class.measure_duration { 42 }

      expect(result).to eq(42)
      expect(duration).to eq(2)
    end
  end

  describe '#with_finished_at' do
    it 'adds a timestamp to the hash yielded by the block' do
      freeze_time do
        result = described_class.with_finished_at(:current_time) { { a: 1 } }

        expect(result).to eq(a: 1, current_time: Time.current)
      end
    end
  end
end
