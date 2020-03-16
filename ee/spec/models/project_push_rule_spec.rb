# frozen_string_literal: true

require 'spec_helper'

describe ProjectPushRule do
  describe "Associations" do
    it { is_expected.to belong_to(:project) }
    it { is_expected.to belong_to(:push_rule) }
  end
end
