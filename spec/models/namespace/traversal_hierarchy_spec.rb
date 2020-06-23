# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Namespace::TraversalHierarchy, type: :model do

  let_it_be(:root) { create(:namespace, :with_hierarchy) }

  # Ensure traversal_ids are reset back to default values.
  after do
    Namespace.update_all(traversal_ids: [])
  end

  describe '.for_namespace' do
    subject { described_class.for_namespace(namespace) }

    context 'with root group' do
      let(:namespace) { root }

      it { is_expected.to eq root }
    end

    context 'with child group' do
      let(:namespace) { root.children.first.children.first }

      it { is_expected.to eq root }
    end

    context 'with group outside of hierarchy' do
      let(:namespace) { create(:namespace) }

      it { is_expected.not_to eq root }
    end
  end

  describe '.new' do
    let(:hierarchy) { described_class.new(root) }

    it { expect(hierarchy.root).to eq root }
  end

  describe '#incorrect_traversal_ids' do
    let(:hierarchy) { described_class.new(root) }

    it { expect(hierarchy.incorrect_traversal_ids).to match_array Namespace.all }
  end

  describe '#sync_traversal_ids!' do
    let(:hierarchy) { described_class.new(root) }

    before do
      hierarchy.sync_traversal_ids!
    end

    it { expect(hierarchy.incorrect_traversal_ids).to be_empty }
  end

end
