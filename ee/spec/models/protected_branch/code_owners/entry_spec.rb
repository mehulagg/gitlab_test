# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ProtectedBranch::CodeOwners::Entry do
  describe 'Associations' do
    it { is_expected.to belong_to(:section) }
  end
end
