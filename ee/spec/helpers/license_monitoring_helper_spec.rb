# frozen_string_literal: true

require 'spec_helper'

RSpec.describe LicenseMonitoringHelper do
  let_it_be(:admin) { create(:admin) }
  let_it_be(:user) { create(:user) }
  let_it_be(:license_seats_limit) { 10 }

  let_it_be(:license) do
    create(:license, data: build(:gitlab_license, restrictions: { active_user_count: license_seats_limit }).export)
  end

  describe '#show_active_user_count_threshold_banner?' do
    subject { helper.show_active_user_count_threshold_banner? }

    shared_examples 'banner hidden when below the threshold' do
      let(:active_user_count) { 1 }

      it { is_expected.to be_falsey }
    end

    context 'on GitLab.com' do
      before do
        allow(Gitlab).to receive(:com?).and_return(true)
      end

      it { is_expected.to be_falsey }
    end

    context 'on self-managed instance' do
      before do
        allow(Gitlab).to receive(:com?).and_return(false)
      end

      context 'when callout dismissed' do
        before do
          allow(helper).to receive(:user_dismissed?).with(UserCalloutsHelper::ACTIVE_USER_COUNT_THRESHOLD).and_return(true)
        end

        it { is_expected.to be_falsey }
      end

      context 'when license' do
        context 'is not available' do
          before do
            allow(License).to receive(:current).and_return(nil)
          end

          it { is_expected.to be_falsey }
        end

        context 'is trial' do
          before do
            allow(License.current).to receive(:trial?).and_return(true)
          end

          it { is_expected.to be_falsey }
        end
      end

      context 'when current active user count greater than total user count' do
        before do
          allow(helper).to receive(:total_user_count).and_return(license_seats_limit)
          allow(helper).to receive(:current_active_users_count).and_return(license_seats_limit + 1)
        end

        it { is_expected.to be_falsey }
      end

      context 'when logged in as an admin user' do
        before do
          allow(helper).to receive(:current_user).and_return(admin)
          allow(helper).to receive(:admin_section?).and_return(true)
          allow(helper).to receive(:current_active_users_count).and_return(active_user_count)
        end

        context 'when above the threshold' do
          let(:active_user_count) { license_seats_limit - 1 }

          it { is_expected.to be_truthy }
        end

        it_behaves_like 'banner hidden when below the threshold'
      end

      context 'when logged in as a regular user' do
        before do
          allow(helper).to receive(:current_user).and_return(user)
        end

        it_behaves_like 'banner hidden when below the threshold'
      end

      context 'when not logged in' do
        before do
          allow(helper).to receive(:current_user).and_return(nil)
        end

        it_behaves_like 'banner hidden when below the threshold'
      end
    end
  end
end
