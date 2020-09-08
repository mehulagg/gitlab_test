# frozen_string_literal: true

require 'spec_helper'

RSpec.describe NamespaceSetting, type: :model do
  it { is_expected.to belong_to(:namespace) }

  describe "Validation" do
    subject { build(:namespace_setting, namespace: group)
end
