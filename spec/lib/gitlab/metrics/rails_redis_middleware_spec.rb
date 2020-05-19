# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Metrics::RailsRedisMiddleware do
  let(:app) { double(:app) }
  let(:middleware) { described_class.new(app) }
  let(:env) { {} }
  let(:transaction) { Gitlab::Metrics::WebTransaction.new(env) }

  before do
    allow(app).to receive(:call).with(env).and_return('wub wub')
  end

  describe '#call' do
    context 'when metrics are disabled' do
      before do
        allow(Gitlab::Metrics).to receive(:current_transaction).and_return(nil)
      end

      it 'calls the app' do
        expect(middleware.call(env)).to eq('wub wub')
      end

      it 'does not record metrics' do
        expect(Gitlab::Metrics).not_to receive(:counter)
        expect(Gitlab::Metrics).not_to receive(:histogram)

        middleware.call(env)
      end
    end

    context 'when metrics are enabled' do
      let(:counter) { double(Prometheus::Client::Histogram, increment: nil) }
      let(:histogram) { double(Prometheus::Client::Histogram, observe: nil) }
      let(:redis_query_time) { 0.1 }
      let(:redis_requests_count) { 2 }

      before do
        allow(Gitlab::Instrumentation::Redis).to receive(:query_time) { redis_query_time }
        allow(Gitlab::Instrumentation::Redis).to receive(:get_request_count) { redis_requests_count }

        allow(Gitlab::Metrics).to receive(:counter).with(:rails_redis_requests_total, an_instance_of(String)) { counter }
        allow(Gitlab::Metrics).to receive(:histogram)
          .with(:rails_redis_requests_duration_seconds, an_instance_of(String), {}, Gitlab::Instrumentation::Redis::QUERY_TIME_BUCKETS)
          .and_return(histogram)

        allow(Gitlab::Metrics).to receive(:current_transaction).and_return(transaction)
      end

      it 'calls the app' do
        expect(middleware.call(env)).to eq('wub wub')
      end

      it 'records redis metrics' do
        expect(counter).to receive(:increment).with(transaction.labels, redis_requests_count)
        expect(histogram).to receive(:observe).with(transaction.labels, redis_query_time)

        middleware.call(env)
      end

      it 'ignores unknown labels' do
        allow(transaction).to receive(:labels)
          .and_return({ controller: 'foo', action: 'bar', unknwon: 'kux' })

        expect(counter).to receive(:increment).with({ controller: 'foo', action: 'bar' }, redis_requests_count)
        expect(histogram).to receive(:observe).with({ controller: 'foo', action: 'bar' }, redis_query_time)

        middleware.call(env)
      end
    end
  end
end
