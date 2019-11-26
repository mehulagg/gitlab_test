# frozen_string_literal: true

shared_examples_for 'a replicable model' do
  it { is_expected.to respond_to(:replicable_create) }
  it { is_expected.to respond_to(:replicable_update) }
  it { is_expected.to respond_to(:replicable_move) }
  it { is_expected.to respond_to(:replicable_delete) }
  it { is_expected.to respond_to(:strategy) }
end
