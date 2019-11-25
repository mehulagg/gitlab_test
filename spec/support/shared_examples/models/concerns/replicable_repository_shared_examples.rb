# frozen_string_literal: true

shared_examples_for 'a replicable repository model' do
  context 'when created' do
    it 'creates a Geo::ReplicableEvent' do
      expect do
        create_replicable_repository
      end.to change { Geo::ReplicableEvent.count }.by(1)

      expect(Geo::ReplicableEvent.last.attributes).to include(
        'event_class_name' => 'Gitlab::Geo::Replicable::Strategies::Repository::Events::CreateEvent',
        'registry_class_name' => 'Geo::DesignRegistry',
        'model_id' => repository.project.id
      )
    end
  end
end
