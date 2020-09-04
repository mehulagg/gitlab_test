# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ProtectedBranch::CodeOwners::File do
  describe 'Associations' do
    it { is_expected.to belong_to(:protected_branch) }
    it { is_expected.to have_many(:sections) }
    it { is_expected.to have_many(:entries) }
  end
end
