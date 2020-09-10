# frozen_string_literal: true

require 'spec_helper'

RSpec.describe NamespaceSetting, type: :model do
  describe "Associations" do
    it { is_expected.to belong_to(:namespace) }
  end

  describe "Validation" do
    subject { build(:namespace_settings, namespace: group) }

    context 'group is top-level group' do
      let(:group) { create(:group) }

      it { is_expected.to be_valid }
    end

    context 'group is a subgroup' do
      let(:group) { create(:group, parent: create(:group)) }

      it { is_expected.to be_invalid }
    end
  end
end
