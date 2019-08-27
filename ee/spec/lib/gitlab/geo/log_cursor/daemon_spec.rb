require 'spec_helper'

describe Gitlab::Geo::LogCursor::Daemon, :clean_gitlab_redis_shared_state do
  include ::EE::GeoHelpers
  include ExclusiveLeaseHelpers

  set(:primary) { create(:geo_node, :primary) }
  set(:secondary) { create(:geo_node) }

  let(:options) { {} }

  subject(:daemon) { described_class.new(options) }

  around do |example|
    Sidekiq::Testing.fake! { example.run }
  end

  before do
    stub_current_geo_node(secondary)

    allow(daemon).to receive(:trap_signals)
    allow(daemon).to receive(:arbitrary_sleep).and_return(0.1)
  end

  # WARNINGS
  #
  # 1. Ensure an exit condition for the main run! loop, or RSpec will not stop
  #    without an interrupt.
  #
  #    I recommend using `ensure_exit_on`.
  #
  # 2. run! occasionally spawns git processes that run forever at 100% CPU.
  #
  #    I don't know why this happens.
  describe '#run!' do
    it 'traps signals' do
      ensure_exit_on(1)
      is_expected.to receive(:trap_signals)

      daemon.run!
    end

    it 'delegates to #run_once! in a loop' do
      ensure_exit_on(4)
      is_expected.to receive(:run_once!).twice

      daemon.run!
    end

    it 'skips execution if cannot achieve a lease' do
      lease = stub_exclusive_lease_taken('geo_log_cursor_processed')

      allow(lease).to receive(:try_obtain_with_ttl).and_return({ ttl: 1, uuid: false })
      allow(lease).to receive(:same_uuid?).and_return(false)
      allow(Gitlab::Geo::LogCursor::Lease).to receive(:exclusive_lease).and_return(lease)

      ensure_exit_on(2)
      is_expected.not_to receive(:run_once!)

      daemon.run!
    end

    it 'skips execution if not a Geo node' do
      stub_current_geo_node(nil)

      ensure_exit_on(2)
      is_expected.to receive(:sleep_break).with(1.minute)
      is_expected.not_to receive(:run_once!)

      daemon.run!
    end

    it 'skips execution if the current node is a primary' do
      stub_current_geo_node(primary)

      ensure_exit_on(2)
      is_expected.to receive(:sleep_break).with(1.minute)
      is_expected.not_to receive(:run_once!)

      daemon.run!
    end

    context 'when health check fails' do
      let(:max) { described_class::MAX_HEALTH_CHECK_FAILURES }

      it 'exits if it has failed too many times' do
        ensure_exit_on(2, false)

        # Disable the throttle
        is_expected.to receive(:health_checked_recently?).and_return(false).exactly(max + 1).times

        # Fail the fresh health checks
        service = double('health check service')
        is_expected.to receive(:health_check_service).and_return(service).exactly(max + 1).times
        expect(service).to receive(:liveness?).and_return(false).exactly(max + 1).times

        max.times do
          daemon.send(:healthy?)
        end

        is_expected.not_to receive(:run_once!)

        daemon.run!
      end

      it 'does not exit if it has not failed many times' do
        ensure_exit_on(2, false)
        is_expected.to receive(:health_checked_recently?).and_return(false).exactly(max).times
        is_expected.to receive(:fresh_checks_healthy?).and_return(false).exactly(max).times

        (max - 1).times do
          daemon.send(:healthy?)
        end

        is_expected.to receive(:run_once!)

        daemon.run!
      end
    end

    context 'health check has never run' do
      it 'checks health' do
        ensure_exit_on(2)
        is_expected.to receive(:fresh_checks_healthy?).and_return(true)

        is_expected.to receive(:run_once!)

        daemon.run!
      end
    end

    context 'health check has run recently' do
      it 'does not check health again' do
        ensure_exit_on(2)
        is_expected.to receive(:run_once!)
        is_expected.to receive(:fresh_checks_healthy?).and_return(true).once

        Timecop.freeze do
          daemon.send(:healthy?)

          Timecop.travel((described_class::HEALTH_CHECK_INTERVAL - 2).seconds) do
            daemon.run!
          end
        end
      end
    end

    context 'health check has run recently' do
      it 'checks health again' do
        ensure_exit_on(2)
        is_expected.to receive(:run_once!)
        is_expected.to receive(:fresh_checks_healthy?).and_return(true).twice

        Timecop.freeze do
          daemon.send(:healthy?)

          Timecop.travel((described_class::HEALTH_CHECK_INTERVAL + 2).seconds) do
            daemon.run!
          end
        end
      end
    end
  end

  describe '#run_once!' do
    context 'with some event logs' do
      let(:project) { create(:project) }
      let(:repository_updated_event) { create(:geo_repository_updated_event, project: project) }
      let(:event_log) { create(:geo_event_log, repository_updated_event: repository_updated_event) }
      let(:batch) { [event_log] }
      let!(:event_log_state) { create(:geo_event_log_state, event_id: event_log.id - 1) }

      it 'handles events' do
        expect(daemon).to receive(:handle_events).with(batch, anything)

        daemon.run_once!
      end

      it 'calls #handle_gap_event for each gap the gap tracking finds' do
        second_event_log = create(:geo_event_log, repository_updated_event: repository_updated_event)

        allow_any_instance_of(::Gitlab::Geo::LogCursor::EventLogs).to receive(:fetch_in_batches)
        allow(daemon.send(:gap_tracking)).to receive(:fill_gaps).and_yield(event_log).and_yield(second_event_log)

        expect(daemon).to receive(:handle_single_event).with(event_log)
        expect(daemon).to receive(:handle_single_event).with(second_event_log)

        daemon.run_once!
      end
    end

    context 'when node has namespace restrictions' do
      let(:group_1) { create(:group) }
      let(:group_2) { create(:group) }
      let(:project) { create(:project, group: group_1) }
      let(:repository_updated_event) { create(:geo_repository_updated_event, project: project) }
      let(:event_log) { create(:geo_event_log, repository_updated_event: repository_updated_event) }
      let!(:event_log_state) { create(:geo_event_log_state, event_id: event_log.id - 1) }
      let!(:registry) { create(:geo_project_registry, :synced, project: project) }

      before do
        allow(Gitlab::ShardHealthCache).to receive(:healthy_shard?).with('default').and_return(true)
        allow(Gitlab::Geo::Logger).to receive(:info).and_call_original
      end

      it 'replays events for projects that belong to selected namespaces to replicate' do
        secondary.update!(namespaces: [group_1])

        expect(Geo::ProjectSyncWorker).to receive(:perform_async).with(project.id, anything).once

        daemon.run_once!
      end

      it 'does not replay events for projects that do not belong to selected namespaces to replicate' do
        secondary.update!(selective_sync_type: 'namespaces', namespaces: [group_2])

        expect(Geo::ProjectSyncWorker).not_to receive(:perform_async).with(project.id, anything)

        daemon.run_once!
      end

      it 'detects when an event was skipped' do
        updated_event = create(:geo_repository_updated_event, project: project)
        new_event = create(:geo_event_log, id: event_log.id + 2, repository_updated_event: updated_event)

        daemon.run_once!

        create(:geo_event_log, id: event_log.id + 1)

        expect(read_gaps).to eq([event_log.id + 1])

        expect(::Geo::EventLogState.last_processed.id).to eq(new_event.id)
      end

      it 'detects when an event was skipped between batches' do
        updated_event = create(:geo_repository_updated_event, project: project)
        new_event = create(:geo_event_log, repository_updated_event: updated_event)

        daemon.run_once!

        create(:geo_event_log, id: new_event.id + 3, repository_updated_event: updated_event)

        daemon.run_once!

        create(:geo_event_log, id: new_event.id + 1, repository_updated_event: updated_event)
        create(:geo_event_log, id: new_event.id + 2, repository_updated_event: updated_event)

        expect(read_gaps).to eq([new_event.id + 1, new_event.id + 2])
      end

      it "logs a message if an associated event can't be found" do
        new_event = create(:geo_event_log)

        expect(Gitlab::Geo::Logger).to receive(:warn)
                                        .with(hash_including(
                                                class: 'Gitlab::Geo::LogCursor::Daemon',
                                                message: '#handle_single_event: unknown event',
                                                event_log_id: new_event.id))

        daemon.run_once!

        expect(::Geo::EventLogState.last_processed.id).to eq(new_event.id)
      end

      it 'logs a message for skipped events' do
        secondary.update!(selective_sync_type: 'namespaces', namespaces: [group_2])

        expect(Gitlab::Geo::Logger).to receive(:info).with(hash_including(
                                                             :pid,
                                                             :cursor_delay_s,
                                                             message: 'Skipped event',
                                                             class: 'Gitlab::Geo::LogCursor::Daemon',
                                                             event_log_id: event_log.id,
                                                             event_id: repository_updated_event.id,
                                                             event_type: 'Geo::RepositoryUpdatedEvent',
                                                             project_id: project.id))

        daemon.run_once!
      end

      it 'does not replay events for projects that do not belong to selected shards to replicate' do
        secondary.update!(selective_sync_type: 'shards', selective_sync_shards: ['broken'])

        expect(Geo::ProjectSyncWorker).not_to receive(:perform_async).with(project.id, anything)

        daemon.run_once!
      end
    end
  end

  describe '#handle_events' do
    let(:batch) { create_list(:geo_event_log, 2) }

    it 'passes the previous batch id on to gap tracking' do
      expect(daemon.send(:gap_tracking)).to receive(:previous_id=).with(55).ordered
      batch.each do |event_log|
        expect(daemon.send(:gap_tracking)).to receive(:previous_id=).with(event_log.id).ordered
      end

      daemon.send(:handle_events, batch, 55)
    end

    it 'checks for gaps for each id in batch' do
      batch.each do |event_log|
        expect(daemon.send(:gap_tracking)).to receive(:check!).with(event_log.id)
      end

      daemon.send(:handle_events, batch, 55)
    end

    it 'handles every single event' do
      batch.each do |event_log|
        expect(daemon).to receive(:handle_single_event).with(event_log)
      end

      daemon.send(:handle_events, batch, 55)
    end
  end

  describe '#handle_single_event' do
    set(:event_log) { create(:geo_event_log, :updated_event) }

    it 'skips execution when no event data is found' do
      event_log = build(:geo_event_log)
      expect(daemon).not_to receive(:can_replay?)

      daemon.send(:handle_single_event, event_log)
    end

    it 'checks if it can replay the event' do
      expect(daemon).to receive(:can_replay?)

      daemon.send(:handle_single_event, event_log)
    end

    it 'processes event when it is replayable' do
      allow(daemon).to receive(:can_replay?).and_return(true)
      expect(daemon).to receive(:process_event).with(event_log.event, event_log)

      daemon.send(:handle_single_event, event_log)
    end
  end

  def read_gaps
    gaps = []

    Timecop.travel(12.minutes) do
      daemon.send(:gap_tracking).send(:fill_gaps) { |event| gaps << event.id }
    end

    gaps
  end

  # It is extremely easy to get run! into an infinite loop.
  #
  # Regardless of `allow` or `expect`, this method ensures that the loop will
  # exit at the specified number of exit? calls.
  def ensure_exit_on(num_calls = 3, expect = true)
    # E.g. If num_calls is `3`, returns is set to `[false, false, true]`.
    returns = Array.new(num_calls) { false }
    returns[-1] = true

    if expect
      expect(daemon).to receive(:exit?).and_return(*returns)
    else
      allow(daemon).to receive(:exit?).and_return(*returns)
    end
  end
end
