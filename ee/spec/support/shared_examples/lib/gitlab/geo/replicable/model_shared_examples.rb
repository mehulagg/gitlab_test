# frozen_string_literal: true

# Essentially defines the interface for a replicable model.
#
# Example:
#
#   class Foo
#     include Gitlab::Geo::Replicable::Model
#   end
#
shared_examples_for 'a replicable model' do
  it { is_expected.to respond_to(:replicable_create) }
  it { is_expected.to respond_to(:replicable_update) }
  it { is_expected.to respond_to(:replicable_move) }
  it { is_expected.to respond_to(:replicable_delete) }
  it { is_expected.to respond_to(:strategy) }
  it { is_expected.to respond_to(:registry) }
  it { is_expected.to respond_to(:replicable_registry_class) }
end
