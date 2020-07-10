# frozen_string_literal: true

require 'spec_helper'

RSpec.describe LaunchType, type: :model do
  subject { build(:launch_type) }

  it { is_expected.to belong_to(:project) }
  it { is_expected.to respond_to(:deploy_target_type) }
  it { is_expected.to delegate_method(:group).to(:project) }

  describe 'validation' do
    it { is_expected.to validate_length_of(:deploy_target_type).is_at_least(1).is_at_most(255) }
  end

  it 'normalize deploy_target_type value' do
    instance = build(:launch_type, deploy_target_type: ' AmAzOn EkS ')

    expect(instance.deploy_target_type).to eq 'amazon eks'
  end
end
