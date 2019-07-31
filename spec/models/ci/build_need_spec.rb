# frozen_string_literal: true

require 'spec_helper'

describe Ci::BuildNeed, model: true do
  it { is_expected.to belong_to(:build) }

  it { is_expected.to validate_presence_of(:name) }
end
