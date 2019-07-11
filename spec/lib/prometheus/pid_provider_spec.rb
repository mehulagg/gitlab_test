# frozen_string_literal: true

require 'fast_spec_helper'

describe Prometheus::PidProvider do
  describe '.worker_id' do
    subject { described_class.worker_id }

    before do
      sidekiq_double = double(Class.new)
      allow(sidekiq_double).to receive(:server?).and_return(false)
      stub_const('Sidekiq', sidekiq_double)
    end

    context 'when initializing Sidekiq' do
      specify do
        expect(Sidekiq).to receive(:server?).and_return(true)

        is_expected.to eq 'sidekiq'
      end
    end

    context 'when initializing Unicorn' do
      before do
        stub_const('Unicorn::Worker', Class.new)
      end

      context 'when `Prometheus::Client::Support::Unicorn` provides worker_id' do
        specify do
          expect(::Prometheus::Client::Support::Unicorn).to receive(:worker_id).and_return(1)

          is_expected.to eq 'unicorn_1'
        end
      end

      context 'when no worker_id is provided from `Prometheus::Client::Support::Unicorn`' do
        specify do
          expect(::Prometheus::Client::Support::Unicorn).to receive(:worker_id).and_return(nil)

          is_expected.to eq 'unicorn_master'
        end
      end
    end

    context 'when initializing Puma' do
      before do
        stub_const('Puma', Class.new)
      end

      context 'when cluster worker id is specified in process name' do
        specify do
          expect(described_class).to receive(:process_name).and_return('puma: cluster worker 1: 17483 [gitlab-puma-worker]')

          is_expected.to eq 'puma_1'
        end
      end

      context 'when no worker id is specified in process name' do
        specify do
          expect(described_class).to receive(:process_name).and_return('bin/puma')

          is_expected.to eq 'puma_master'
        end
      end
    end

    context 'when initializing neither Sidekiq/nor Unicorn/nor Puma' do
      it { is_expected.to eq "process_#{Process.pid}" }
    end
  end
end
