# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ProtectedBranch::CodeOwners::Section do
  describe 'Associations' do
    it { is_expected.to belong_to(:file) }
    it { is_expected.to have_many(:entries) }
  end
end
