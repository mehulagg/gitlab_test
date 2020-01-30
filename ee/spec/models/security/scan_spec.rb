# frozen_string_literal: true

require 'spec_helper'

describe Security::Scan do
  describe 'associations' do
    it { is_expected.to belong_to(:build) }
    it { is_expected.to belong_to(:pipeline) }
  end

  it_behaves_like 'having unique enum values'
end
