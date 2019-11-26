# frozen_string_literal: true

# White-box system tests (way faster than true E2E) for replication.
#
# The user of these shared examples must define:
#
#   - repository
#   - create_repository
#   - update_repository
#   - registry_class
#
shared_examples_for 'a replicable repository feature' do
  include EE::GeoHelpers

  let(:primary) { create(:geo_node, :primary) }
  let(:secondary) { create(:geo_node) }

  before do
    stub_current_geo_node(primary)
    stub_healthy_shards('default')

    # We can't exercise the actual git fetch from "this" machine to the
    # "primary", and it doesn't seem worth exercising any code deeper than this.
    expect_next_instance_of(registry_class.sync_service_class) do |sync_service|
      expect(sync_service).to receive(:fetch_repository)
    end
  end

  context 'syncing' do
    # Creating a repository on the primary results in that repository being synced
    # on the secondary.
    specify 'create repository on primary syncs on secondary', :sidekiq_inline do
      # Create repository should insert a CreateEvent
      create_repository

      # Switch universe to the secondary
      stub_current_geo_node(secondary)

      consume_events(Gitlab::Geo::Replicable::Strategies::Repository::Events::CreateEvent)

      expect(repository.registry).to be_synced
    end

    # Updating a repository on the primary results in that repository being synced
    # on the secondary.
    specify 'update repository on primary syncs on secondary', :sidekiq_inline do
      create_repository

      # Get rid of the Create event
      Geo::ReplicableEvent.delete_all

      # Updating the repository should insert an UpdateEvent
      update_repository

      # Switch universe to the secondary
      stub_current_geo_node(secondary)

      consume_events(Gitlab::Geo::Replicable::Strategies::Repository::Events::UpdateEvent)

      expect(repository.registry).to be_synced
    end
  end

  # Deleting a repository on the primary results in that repository and its
  # registry being deleted on the secondary.
  specify 'delete repository on primary deletes on secondary', :sidekiq_inline do
    # Create repository should insert a CreateEvent
    create_repository

    # Switch universe to the secondary
    stub_current_geo_node(secondary)

    consume_events(Gitlab::Geo::Replicable::Strategies::Repository::Events::CreateEvent)

    expect(repository.registry).to be_synced

    # Switch universe to the primary
    stub_current_geo_node(primary)

    # Destroy project should insert a DeleteEvent for the repository at some point
    repository.project.destroy

    # Switch universe to the secondary
    stub_current_geo_node(secondary)

    # TODO Assert repo exists

    # TODO Consume events
    # consume_events(Gitlab::Geo::Replicable::Strategies::Repository::Events::DeleteEvent)

    # TODO Registry should be deleted
    # expect(repository.registry).to be_nil

    # TODO Assert repo no longer exists
  end

  # On secondaries, Geo::Replicable::ConsumeEventsWorker is constantly
  # consuming all events. We need to trigger what it does here.
  #
  # For now, just "consume" the event directly.
  #
  # TODO Spawn ConsumeEventsWorker or call a method or call the service it
  # calls.
  def consume_events(event_class_name)
    expect do
      last_event = Geo::ReplicableEvent.where(event_class_name: event_class_name.to_s).last
      last_event.consume
    end.to change { registry_class.count }.by(1)
  end
end
