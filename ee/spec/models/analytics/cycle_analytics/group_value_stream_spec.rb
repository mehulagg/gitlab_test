# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::CycleAnalytics::GroupValueStream, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:group) }
    it { is_expected.to have_many(:cycle_analytics_stages) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:group) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_most(100) }
  end
end
