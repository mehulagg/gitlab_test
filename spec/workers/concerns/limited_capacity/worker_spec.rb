# frozen_string_literal: true

require 'spec_helper'

RSpec.describe LimitedCapacity::Worker do
  let(:worker_class) do
    Class.new do
      def self.name
        'DummyWorker'
      end

      include ApplicationWorker
      include LimitedCapacity::Worker
    end
  end

  let(:worker) { worker_class.new }

  describe 'required methods' do
    it { expect { worker.perform_work }.to raise_error(NotImplementedError) }
    it { expect { worker.remaining_work_count }.to raise_error(NotImplementedError) }
    it { expect { worker.max_running_jobs }.to raise_error(NotImplementedError) }
  end

  describe '.perform_with_capacity' do
    subject(:perform_with_capacity) { worker_class.perform_with_capacity(:arg) }

    before do
      expect_next_instance_of(worker_class) do |instance|
        expect(instance).to receive(:remove_completed_jobs_from_queue_set)
        expect(instance).to receive(:report_prometheus_metrics)
        expect(instance).to receive(:remaining_work_count).and_return(remaining_work_count)
        expect(instance).to receive(:remaining_capacity).and_return(remaining_capacity)
      end
    end

    context 'when capacity is larger than work' do
      let(:remaining_work_count) { 2 }
      let(:remaining_capacity) { 3 }

      it 'enqueues jobs for remaining work' do
        expect(worker_class)
          .to receive(:bulk_perform_async)
          .with([[:arg], [:arg]])

        perform_with_capacity
      end
    end

    context 'when capacity is lower than work' do
      let(:remaining_work_count) { 5 }
      let(:remaining_capacity) { 3 }

      it 'enqueues jobs for remaining work' do
        expect(worker_class)
          .to receive(:bulk_perform_async)
          .with([[:arg], [:arg], [:arg]])

        perform_with_capacity
      end
    end
  end

  describe '#perform' do
    subject(:perform) { worker.perform(:arg) }

    before do
      expect(worker).to receive(:has_capacity?).and_return(capacity)
    end

    context 'with capacity' do
      let(:capacity) { true }

      before do
        allow(worker).to receive(:can_re_enqueue?).and_return(true)
      end

      it 'calls perform_work' do
        expect(worker).to receive(:perform_work).with(:arg)

        perform
      end

      it 're-enqueues itself' do
        allow(worker).to receive(:perform_work)
        expect(worker).to receive(:re_enqueue).with(:arg)

        perform
      end

      it 'registers itself in the running set' do
        allow(worker).to receive(:perform_work)
        expect(worker).to receive(:register_running_job_for_queue)

        perform
      end

      it 'removes itself from the running set' do
        allow(worker).to receive(:perform_work)
        expect(worker).to receive(:remove_job_from_running_for_queue)

        perform
      end

      it 'reports prometheus metrics' do
        allow(worker).to receive(:perform_work)
        expect(worker).to receive(:report_prometheus_metrics)

        perform
      end
    end

    context 'with capacity and without work' do
      let(:capacity) { true }

      before do
        allow(worker).to receive(:can_re_enqueue?).and_return(false)
        allow(worker).to receive(:perform_work)
      end

      it 'does not re-enqueue itself' do
        expect(worker_class).not_to receive(:perform_async)

        perform
      end
    end

    context 'without capacity' do
      let(:capacity) { false }

      it 'does not call perform_work' do
        expect(worker).not_to receive(:perform_work)

        perform
      end

      it 'does not re-enqueue itself' do
        expect(worker).not_to receive(:re_enqueue)

        perform
      end

      it 'registers itself in the running set' do
        expect(worker).to receive(:register_running_job_for_queue)

        perform
      end

      it 'removes itself from the running set' do
        expect(worker).to receive(:remove_job_from_running_for_queue)

        perform
      end

      it 'reports prometheus metrics' do
        expect(worker).to receive(:report_prometheus_metrics)

        perform
      end
    end

    context 'when perform_work fails' do
      let(:capacity) { true }

      it 'does not re-enqueue itself' do
        expect(worker).not_to receive(:re_enqueue)

        expect { perform }.to raise_error(NotImplementedError)
      end

      it 'removes itself from the running set' do
        expect(worker).to receive(:remove_job_from_running_for_queue)

        expect { perform }.to raise_error(NotImplementedError)
      end

      it 'reports prometheus metrics' do
        expect(worker).to receive(:report_prometheus_metrics)

        expect { perform }.to raise_error(NotImplementedError)
      end
    end
  end

  describe '#remaining_capacity', :clean_gitlab_redis_shared_state do
    subject(:remaining_capacity) { worker.remaining_capacity }

    before do
      expect(worker).to receive(:max_running_jobs).and_return(max_capacity)
    end

    context 'when changing the capacity to a lower value' do
      let(:max_capacity) { -1 }

      it { expect(remaining_capacity).to eq(0) }
    end

    context 'when registering new jobs' do
      let(:max_capacity) { 2 }

      before do
        worker.send(:register_running_job_for_queue, 'job-id')
      end

      it { expect(remaining_capacity).to eq(1) }
    end

    context 'with jobs in the queue' do
      let(:max_capacity) { 2 }

      before do
        expect(worker_class).to receive(:queue_size).and_return(1)
      end

      it { expect(remaining_capacity).to eq(1) }
    end

    context 'with both running jobs and queued jobs' do
      let(:max_capacity) { 10 }

      before do
        expect(worker_class).to receive(:queue_size).and_return(5)
        expect(worker).to receive(:running_jobs).and_return(3)
      end

      it { expect(remaining_capacity).to eq(2) }
    end
  end

  describe '#remove_completed_jobs_from_queue_set', :clean_gitlab_redis_shared_state, :clean_gitlab_redis_queues do
    subject(:remove_failed_jobs) { worker.remove_completed_jobs_from_queue_set }

    context 'with failed jobs' do
      before do
        worker.send(:register_running_job_for_queue, 'failed-job-id')

        expect(worker).to receive(:max_running_jobs).twice.and_return(2)

        expect(Gitlab::SidekiqStatus).to receive(:completed_jids)
          .with(%w[failed-job-id])
          .and_return(%w[failed-job-id])
      end

      it 'update the available capacity' do
        expect { remove_failed_jobs }.to change { worker.remaining_capacity }.by(1)
      end
    end

    context 'with running jobs' do
      before do
        worker.send(:register_running_job_for_queue, 'running-job-id')

        expect(worker).to receive(:max_running_jobs).twice.and_return(2)

        expect(Gitlab::SidekiqStatus).to receive(:completed_jids)
          .with(%w[running-job-id])
          .and_return([])
      end

      it 'update the available capacity' do
        expect { remove_failed_jobs }.not_to change { worker.remaining_capacity }
      end
    end
  end

  describe '#report_prometheus_metrics' do
    subject(:report_prometheus_metrics) { worker.report_prometheus_metrics }

    it 'reports number of running jobs' do
      expect(worker).to receive(:running_jobs).and_return(5)

      report_prometheus_metrics

      expect(Gitlab::Metrics.registry.get(:limited_capacity_worker_running_jobs).get({ worker: 'DummyWorker' })).to eq(5)
    end
  end

  describe '#can_re_enqueue?' do
    using RSpec::Parameterized::TableSyntax

    subject(:can_re_enqueue) { worker.send(:can_re_enqueue?) }

    before do
      allow(worker).to receive(:has_capacity?).and_return(capacity)
      allow(worker).to receive(:has_work?).and_return(work)
    end

    where(:capacity, :work, :expected) do
      true  | true   | true
      true  | false  | false
      false | true   | false
      false | false  | false
    end

    with_them do
      it { expect(can_re_enqueue).to eq(expected) }
    end
  end
end
