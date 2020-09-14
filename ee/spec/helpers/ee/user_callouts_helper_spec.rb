# frozen_string_literal: true

require "spec_helper"

RSpec.describe EE::UserCalloutsHelper do
  using RSpec::Parameterized::TableSyntax

  describe '.render_enable_hashed_storage_warning' do
    context 'when we should show the enable warning' do
      it 'renders the enable warning' do
        expect(helper).to receive(:show_enable_hashed_storage_warning?).and_return(true)

        expect(helper).to receive(:render_flash_user_callout)
          .with(:warning,
            /Please enable and migrate to hashed/,
            EE::UserCalloutsHelper::GEO_ENABLE_HASHED_STORAGE)

        helper.render_enable_hashed_storage_warning
      end
    end

    context 'when we should not show the enable warning' do
      it 'does not render the enable warning' do
        expect(helper).to receive(:show_enable_hashed_storage_warning?).and_return(false)

        expect(helper).not_to receive(:render_flash_user_callout)

        helper.render_enable_hashed_storage_warning
      end
    end
  end

  describe '.render_migrate_hashed_storage_warning' do
    context 'when we should show the migrate warning' do
      it 'renders the migrate warning' do
        expect(helper).to receive(:show_migrate_hashed_storage_warning?).and_return(true)

        expect(helper).to receive(:render_flash_user_callout)
          .with(:warning,
            /Please migrate all existing projects/,
            EE::UserCalloutsHelper::GEO_MIGRATE_HASHED_STORAGE)

        helper.render_migrate_hashed_storage_warning
      end
    end

    context 'when we should not show the migrate warning' do
      it 'does not render the migrate warning' do
        expect(helper).to receive(:show_migrate_hashed_storage_warning?).and_return(false)

        expect(helper).not_to receive(:render_flash_user_callout)

        helper.render_migrate_hashed_storage_warning
      end
    end
  end

  describe '.show_enable_hashed_storage_warning?' do
    subject { helper.show_enable_hashed_storage_warning? }

    let(:user) { create(:user) }

    context 'when hashed storage is disabled' do
      before do
        stub_application_setting(hashed_storage_enabled: false)
        allow(helper).to receive(:current_user).and_return(user)
      end

      context 'when the enable warning has not been dismissed' do
        it { is_expected.to be_truthy }
      end

      context 'when the enable warning was dismissed' do
        before do
          create(:user_callout, user: user, feature_name: described_class::GEO_ENABLE_HASHED_STORAGE)
        end

        it { is_expected.to be_falsy }
      end
    end

    context 'when hashed storage is enabled' do
      before do
        stub_application_setting(hashed_storage_enabled: true)
      end

      it { is_expected.to be_falsy }
    end
  end

  describe '.show_migrate_hashed_storage_warning?' do
    subject { helper.show_migrate_hashed_storage_warning? }

    let(:user) { create(:user) }

    context 'when hashed storage is disabled' do
      before do
        stub_application_setting(hashed_storage_enabled: false)
      end

      it { is_expected.to be_falsy }
    end

    context 'when hashed storage is enabled' do
      before do
        stub_application_setting(hashed_storage_enabled: true)
        allow(helper).to receive(:current_user).and_return(user)
      end

      context 'when the enable warning has not been dismissed' do
        context 'when there is a project in non-hashed-storage' do
          before do
            create(:project, :legacy_storage)
          end

          it { is_expected.to be_truthy }
        end

        context 'when there are NO projects in non-hashed-storage' do
          it { is_expected.to be_falsy }
        end
      end

      context 'when the enable warning was dismissed' do
        before do
          create(:user_callout, user: user, feature_name: described_class::GEO_MIGRATE_HASHED_STORAGE)
        end

        it { is_expected.to be_falsy }
      end
    end
  end

  describe '.show_canary_deployment_callout?' do
    let(:project) { build(:project) }

    subject { helper.show_canary_deployment_callout?(project) }

    before do
      allow(helper).to receive(:show_promotions?).and_return(true)
    end

    context 'when user needs to upgrade to canary deployments' do
      before do
        allow(project).to receive(:feature_available?).with(:deploy_board).and_return(false)
      end

      context 'when user has dismissed' do
        before do
          allow(helper).to receive(:user_dismissed?).and_return(true)
        end

        it { is_expected.to be_falsey }
      end

      context 'when user has not dismissed' do
        before do
          allow(helper).to receive(:user_dismissed?).and_return(false)
        end

        it { is_expected.to be_truthy }
      end
    end

    context 'when user already has access to canary deployments' do
      before do
        allow(project).to receive(:feature_available?).with(:deploy_board).and_return(true)
        allow(helper).to receive(:user_dismissed?).and_return(false)
      end

      it { is_expected.to be_falsey }
    end
  end

  describe '#render_dashboard_gold_trial' do
    let_it_be(:namespace) { create(:namespace) }
    let_it_be(:gold_plan) { create(:gold_plan) }
    let(:user) { namespace.owner }

    where(:any_namespace_without_trial?, :show_gold_trial?, :user_default_dashboard?, :has_no_trial_or_paid_plan?, :should_render?) do
      true  | true  | true  | true  | true
      true  | true  | true  | false | false
      true  | true  | false | true  | false
      true  | false | true  | true  | false
      true  | true  | false | false | false
      true  | false | false | true  | false
      true  | false | true  | false | false
      true  | false | false | false | false
      false | true  | true  | true  | false
      false | true  | true  | false | false
      false | true  | false | true  | false
      false | false | true  | true  | false
      false | true  | false | false | false
      false | false | false | true  | false
      false | false | true  | false | false
      false | false | false | false | false
    end

    with_them do
      before do
        allow(helper).to receive(:show_gold_trial?) { show_gold_trial? }
        allow(helper).to receive(:user_default_dashboard?) { user_default_dashboard? }
        allow(user).to receive(:any_namespace_without_trial?) { any_namespace_without_trial? }

        unless has_no_trial_or_paid_plan?
          create(:gitlab_subscription, hosted_plan: gold_plan, namespace: namespace)
        end
      end

      it do
        if should_render?
          expect(helper).to receive(:render).with('shared/gold_trial_callout_content')
        else
          expect(helper).not_to receive(:render)
        end

        helper.render_dashboard_gold_trial(user)
      end
    end

    context 'when render_dashboard_gold_trial feature is disabled' do
      before do
        stub_feature_flags(render_dashboard_gold_trial: false)

        allow(helper).to receive(:show_gold_trial?).and_return(true)
        allow(helper).to receive(:user_default_dashboard?).and_return(true)
        allow(helper).to receive(:has_some_namespaces_with_no_trials?).and_return(true)
      end

      it 'does not render' do
        expect(helper).not_to receive(:render)

        helper.render_dashboard_gold_trial(user)
      end
    end
  end

  describe '#render_billings_gold_trial' do
    let(:namespace) { create(:namespace) }
    let_it_be(:free_plan) { create(:free_plan) }
    let_it_be(:silver_plan) { create(:silver_plan) }
    let_it_be(:gold_plan) { create(:gold_plan) }
    let(:user) { namespace.owner }

    where(:never_had_trial?, :show_gold_trial?, :gold_plan?, :free_plan?, :should_render?) do
      true  | true  | false | false | true
      true  | true  | false | true  | true
      true  | true  | true  | true  | false
      true  | true  | true  | false | false
      true  | false | true  | true  | false
      true  | false | false | true  | false
      true  | false | true  | false | false
      true  | false | false | false | false
      false | true  | false | false | false
      false | true  | false | true  | false
      false | true  | true  | true  | false
      false | true  | true  | false | false
      false | false | true  | true  | false
      false | false | false | true  | false
      false | false | true  | false | false
      false | false | false | false | false
    end

    with_them do
      before do
        allow(helper).to receive(:show_gold_trial?) { show_gold_trial? }

        if !never_had_trial?
          create(:gitlab_subscription, namespace: namespace, hosted_plan: free_plan, trial_ends_on: Date.yesterday)
        elsif gold_plan?
          create(:gitlab_subscription, namespace: namespace, hosted_plan: gold_plan)
        elsif !free_plan?
          create(:gitlab_subscription, namespace: namespace, hosted_plan: silver_plan)
        end
      end

      it do
        if should_render?
          expect(helper).to receive(:render).with('shared/gold_trial_callout_content', is_dismissable: !free_plan?, callout: UserCalloutsHelper::GOLD_TRIAL_BILLINGS)
        else
          expect(helper).not_to receive(:render)
        end

        helper.render_billings_gold_trial(user, namespace)
      end
    end
  end

  describe '#render_account_recovery_regular_check' do
    let(:new_user) { create(:user) }
    let(:old_user) { create(:user, created_at: 4.months.ago )}
    let(:anonymous) { nil }

    where(:kind_of_user, :is_gitlab_com?, :dismissed_callout?, :should_render?) do
      :anonymous | false | false | false
      :anonymous | true  | false | false
      :new_user  | false | false | false
      :new_user  | true  | false | false
      :old_user  | false | false | false
      :old_user  | true  | false | true
      :old_user  | false | true  | false
      :old_user  | true  | true  | false
    end

    with_them do
      before do
        user = send(kind_of_user)
        allow(helper).to receive(:current_user).and_return(user)
        allow(Gitlab).to receive(:com?).and_return(is_gitlab_com?)
        allow(user).to receive(:dismissed_callout?).and_return(dismissed_callout?) if user
      end

      it do
        if should_render?
          expect(helper).to receive(:render).with('shared/check_recovery_settings')
        else
          expect(helper).not_to receive(:render)
        end

        helper.render_account_recovery_regular_check
      end
    end
  end

  describe '.show_threat_monitoring_info?' do
    subject { helper.show_threat_monitoring_info? }

    let(:user) { create(:user) }

    before do
      allow(helper).to receive(:current_user).and_return(user)
    end

    context 'when the threat monitoring info has not been dismissed' do
      it { is_expected.to be_truthy }
    end

    context 'when the threat monitoring info was dismissed' do
      before do
        create(:user_callout, user: user, feature_name: described_class::THREAT_MONITORING_INFO)
      end

      it { is_expected.to be_falsy }
    end
  end

  describe '.show_feature_flags_new_version?' do
    subject { helper.show_feature_flags_new_version? }

    let(:user) { create(:user) }

    before do
      allow(helper).to receive(:current_user).and_return(user)
    end

    context 'when the feature flags new version info has not been dismissed' do
      it { is_expected.to be_truthy }
    end

    context 'when the feature flags new version has been dismissed' do
      before do
        create(:user_callout, user: user, feature_name: described_class::FEATURE_FLAGS_NEW_VERISION)
      end

      it { is_expected.to be_falsy }
    end
  end

  describe '.show_token_expiry_notification?' do
    subject { helper.show_token_expiry_notification? }

    let_it_be(:user) { create(:user) }

    where(:expiration_enforced?, :dismissed_callout?, :active?, :result) do
      true  | true  | true  | false
      true  | true  | false | false
      true  | false | true  | false
      false | true  | true  | false
      true  | false | false | false
      false | false | true  | true
      false | true  | false | false
      false | false | false | false
    end

    with_them do
      before do
        allow(helper).to receive(:current_user).and_return(user)
        allow(user).to receive(:active?).and_return(active?)
        allow(helper).to receive(:token_expiration_enforced?).and_return(expiration_enforced?)
        allow(user).to receive(:dismissed_callout?).and_return(dismissed_callout?)
      end

      it do
        expect(subject).to be result
      end

      context 'when user is nil' do
        before do
          allow(helper).to receive(:current_user).and_return(nil)
          allow(helper).to receive(:token_expiration_enforced?).and_return(false)
        end

        it do
          expect(subject).to be false
        end
      end
    end
  end
end
