# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Prometheus::PidProvider do
  describe '#worker_id' do
    subject { described_class.worker_id }

    context 'when initializing Sidekiq' do
      before do
        allow(Sidekiq).to receive(:server?).and_return(true)
      end

      it { is_expected.to eq 'sidekiq' }
    end

    context 'when initializing Unicorn' do
      before do
        stub_const('Unicorn::Worker', Class.new)
      end

      context 'when `Prometheus::Client::Support::Unicorn` provides worker_id' do
        before do
          allow(::Prometheus::Client::Support::Unicorn).to receive(:worker_id).and_return(1)
        end

        it { is_expected.to eq 'unicorn_1' }
      end

      context 'when no worker_id is provided from `Prometheus::Client::Support::Unicorn`' do
        before do
          allow(::Prometheus::Client::Support::Unicorn).to receive(:worker_id).and_return(nil)
        end

        it { is_expected.to eq 'unicorn_master' }
      end
    end

    context 'when initializing Puma' do
      before do
        stub_const('Puma', Class.new)
      end

      context 'when cluster worker id is specified in `$0`' do
        it 'includes worker id' do
          old_value = $0

          begin
            $0 = 'puma: cluster worker 1: 17483 [gitlab-puma-worker]'

            expect(subject).to eq 'puma_1'
          ensure
            $0 = old_value
          end
        end
      end

      context 'when no worker id is specified in `$0`' do
        it { is_expected.to eq 'puma_master' }
      end
    end

    context 'when initializing neither Sidekiq/nor Unicorn/nor Puma' do
      it { is_expected.to eq "process_#{Process.pid}" }
    end
  end
end
