# frozen_string_literal: true

require 'spec_helper'

describe SubscriptionsHelper do
  describe '#subscription_data' do
    let(:raw_plan_data) do
      [
        {
          "name" => "Free Plan",
          "free" => true
        },
        {
          "id" => "bronze_id",
          "name" => "Bronze Plan",
          "free" => false,
          "code" => "bronze",
          "price_per_year" => 48.0
        }
      ]
    end
    let(:user) { create(:user, setup_for_company: true, name: 'First Last') }

    before do
      allow(helper).to receive(:current_user).and_return(user)
      allow(helper).to receive(:params).and_return(plan_id: 'bronze_id')
      allow_any_instance_of(FetchSubscriptionPlansService).to receive(:execute).and_return(raw_plan_data)
    end

    subject { helper.subscription_data }

    it { is_expected.to include(setup_for_company: 'true') }
    it { is_expected.to include(full_name: 'First Last') }
    it { is_expected.to include(plan_data: '[{"id":"bronze_id","code":"bronze","price_per_year":48.0}]') }
    it { is_expected.to include(plan_id: 'bronze_id') }
  end
end
