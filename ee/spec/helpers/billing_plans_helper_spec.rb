# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BillingPlansHelper do
  describe '#subscription_plan_data_attributes' do
    let(:customer_portal_url) { "#{EE::SUBSCRIPTIONS_URL}/subscriptions" }

    let(:group) { build(:group) }
    let(:plan) do
      Hashie::Mash.new(id: 'external-paid-plan-hash-code')
    end

    context 'when group and plan with ID present' do
      it 'returns data attributes' do
        upgrade_href =
          "#{EE::SUBSCRIPTIONS_URL}/gitlab/namespaces/#{group.id}/upgrade/#{plan.id}"

        expect(helper.subscription_plan_data_attributes(group, plan))
          .to eq(namespace_id: group.id,
                 namespace_name: group.name,
                 plan_upgrade_href: upgrade_href,
                 customer_portal_url: customer_portal_url)
      end
    end

    context 'when group not present' do
      let(:group) { nil }

      it 'returns empty data attributes' do
        expect(helper.subscription_plan_data_attributes(group, plan)).to eq({})
      end
    end

    context 'when plan with ID not present' do
      let(:plan) { Hashie::Mash.new(id: nil) }

      it 'returns data attributes without upgrade href' do
        expect(helper.subscription_plan_data_attributes(group, plan))
          .to eq(namespace_id: group.id,
                 namespace_name: group.name,
                 customer_portal_url: customer_portal_url,
                 plan_upgrade_href: nil)
      end
    end
  end

  describe '#use_new_purchase_flow?' do
    where type: ['Group', nil],
          plan: Plan.all_plans

    with_them do
      let_it_be(:user) { create(:user) }
      let(:namespace) do
        create :namespace, type: type,
               gitlab_subscription: create(:gitlab_subscription, hosted_plan: create("#{plan}_plan".to_sym))
      end

      before do
        allow(helper).to receive(:current_user).and_return(user)
      end

      subject { helper.use_new_purchase_flow?(namespace) }

      it do
        result = type == 'Group' && plan == Plan::FREE

        is_expected.to be(result)
      end
    end
  end

  describe '#show_contact_sales_button?' do
    using RSpec::Parameterized::TableSyntax

    where(:experiment_enabled, :link_action, :result) do
      true | 'downgrade' | false
      true | 'current' | false
      true | 'upgrade' | true
      false | 'downgrade' | false
      false | 'current' | false
      false | 'upgrade' | false
    end

    with_them do
      before do
        allow(helper).to receive(:experiment_enabled?).with(:contact_sales_btn_in_app).and_return(experiment_enabled)
      end

      subject { helper.show_contact_sales_button?(link_action) }

      it { is_expected.to eq(result) }
    end
  end

  describe '#experiment_tracking_data_for_button_click' do
    let(:button_label) { 'some_label' }
    let(:experiment_enabled) { false }

    subject { helper.experiment_tracking_data_for_button_click(button_label) }

    before do
      stub_experiment(contact_sales_btn_in_app: experiment_enabled)
    end

    context 'when the experiment is not enabled' do
      it { is_expected.to eq({}) }
    end

    context 'when the experiment is enabled' do
      let(:experiment_enabled) { true }

      before do
        allow(helper).to receive(:experiment_tracking_category_and_group).with(:contact_sales_btn_in_app).and_return("Category:control_group")
      end

      it 'returns a hash to be used as data-attributes in a view' do
        is_expected.to eq({
          track: {
            event: 'click_button',
            label: button_label,
            property: 'Category:control_group'
          }
        })
      end
    end
  end
end
