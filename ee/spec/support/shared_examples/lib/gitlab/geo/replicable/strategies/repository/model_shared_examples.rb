# frozen_string_literal: true

# The caller of these shared examples must define:
#
#   - repository
#   - create_repository
#   - update_repository
#   - registry_class
#
shared_examples_for 'a replicable repository model' do
  context 'when created' do
    it 'creates a Geo::ReplicableEvent' do
      expect do
        create_repository
      end.to change { Geo::ReplicableEvent.count }.by(1)

      expect(Geo::ReplicableEvent.last.attributes).to include(
        'event_class_name' => 'Gitlab::Geo::Replicable::Strategies::Repository::Events::CreateEvent',
        'registry_class_name' => registry_class.name,
        'model_id' => repository.project.id
      )
    end
  end
end
