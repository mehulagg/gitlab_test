# frozen_string_literal: true

# Include these shared examples in specs of Replicators that include
# BlobReplicatorStrategy.
#
# A let variable called model_record should be defined in the spec. It should be
# a valid, unpersisted instance of the model class.
#
RSpec.shared_examples 'a repository replicator' do
  include EE::GeoHelpers

  let_it_be(:primary) { create(:geo_node, :primary) }
  let_it_be(:secondary) { create(:geo_node) }

  subject(:replicator) { model_record.replicator }

  before do
    stub_current_geo_node(primary)
  end

  it_behaves_like 'a replicator'

  # This could be included in each model's spec, but including it here is DRYer.
  include_examples 'a replicable model'

  describe '#handle_after_update' do
    it 'creates a Geo::Event' do
      expect do
        replicator.handle_after_update
      end.to change { ::Geo::Event.count }.by(1)

      expect(::Geo::Event.last.attributes).to include(
        "replicable_name" => replicator.replicable_name, "event_name" => "updated", "payload" => { "model_record_id" => replicator.model_record.id })
    end

    context 'when replication feature flag is disabled' do
      before do
        stub_feature_flags(replicator.replication_enabled_feature_key => false)
      end

      it 'does not publish' do
        expect(replicator).not_to receive(:publish)

        replicator.handle_after_update
      end
    end
  end

  describe '#handle_after_destroy' do
    it 'creates a Geo::Event' do
      expect do
        replicator.handle_after_destroy
      end.to change { ::Geo::Event.count }.by(1)

      expect(::Geo::Event.last.attributes).to include(
        "replicable_name" => replicator.replicable_name, "event_name" => "deleted")
      expect(::Geo::Event.last.payload).to include({ "model_record_id" => replicator.model_record.id })
    end

    context 'when replication feature flag is disabled' do
      before do
        stub_feature_flags("geo_#{replicator.replicable_name}_replication": false)
      end

      it 'does not publish' do
        expect(replicator).not_to receive(:publish)

        replicator.handle_after_destroy
      end
    end
  end

  describe '#consume_event_updated' do
    context 'in replicables_for_geo_node list' do
      it 'runs SnippetRepositorySyncService service' do
        model_record.save!

        sync_service = double

        expect(sync_service).to receive(:execute)

        expect(::Geo::FrameworkRepositorySyncService)
          .to receive(:new).with(replicator: replicator)
                .and_return(sync_service)

        replicator.consume_event_updated({})
      end
    end

    context 'not in replicables_for_geo_node list' do
      it 'runs SnippetRepositorySyncService service' do
        expect(::Geo::FrameworkRepositorySyncService)
          .not_to receive(:new)

        replicator.consume_event_updated({})
      end
    end
  end

  describe '#consume_event_deleted' do
    context 'in replicables_for_geo_node list' do
      it 'runs Repositories::DestroyService service' do
        model_record.save!

        sync_service = double

        expect(sync_service).to receive(:execute).and_return({ status: :success })

        expect(::Repositories::DestroyService)
          .to receive(:new).with(replicator.repository)
                .and_return(sync_service)

        replicator.consume_event_deleted({})
      end
    end

    context 'not in replicables_for_geo_node list' do
      it 'runs SnippetRepositorySyncService service' do
        expect(::Repositories::DestroyService)
          .not_to receive(:new)

        replicator.consume_event_deleted({})
      end
    end
  end

  describe '#model' do
    let(:invoke_model) { replicator.class.model }

    it 'is implemented' do
      expect do
        invoke_model
      end.not_to raise_error
    end

    it 'is a Class' do
      expect(invoke_model).to be_a(Class)
    end
  end
end
