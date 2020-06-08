# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::PersonalAccessTokens::RotationVerifier do
  let_it_be(:user) { create(:user) }
  let_it_be(:no_pat_user) { create(:user) }
  let_it_be(:active_pat) { create(:personal_access_token, user: user, expires_at: 2.months.from_now, created_at: 1.month.ago) }

  shared_examples 'rotation required' do
    it { is_expected.to be true }
  end

  shared_examples 'rotation NOT required' do
    it { is_expected.to be false }
  end

  describe '#expired?' do
    subject { described_class.new(user).expired? }

    let_it_be(:recent_expired_pat) { create(:personal_access_token, :expired, user: user, created_at: 1.month.ago) }

    context 'when no new token was created after notification for expired token started' do
      it_behaves_like 'rotation required'
    end

    context 'when token was created after notification for expired token started' do
      before do
        create(:personal_access_token, user: user, created_at: recent_expired_pat.expires_at + 1.day)
      end

      it_behaves_like 'rotation NOT required'
    end

    context 'with multiple expired tokens' do
      let_it_be(:expired_pat1) { create(:personal_access_token, expires_at: 12.days.ago, user: user, created_at: 1.month.ago) }

      context 'when no new token was created after notification for expired token started' do
        it_behaves_like 'rotation required'
      end

      context 'when new token was created after notification for ONLY first expired token started' do
        before do
          create(:personal_access_token, user: user, created_at: expired_pat1.expires_at + 1.day)
        end

        it_behaves_like 'rotation required'
      end

      context 'when new token was created after notification for most recent expired token started' do
        before do
          create(:personal_access_token, user: user, created_at: recent_expired_pat.expires_at + 1.day)
        end

        it_behaves_like 'rotation NOT required'
      end
    end

    context 'For user with no PATs' do
      subject { described_class.new(no_pat_user).expired? }

      it_behaves_like 'rotation NOT required'
    end
  end

  describe '#expiring_soon?' do
    subject { described_class.new(user).expiring_soon? }

    let_it_be(:recent_expiring_pat) { create(:personal_access_token, user: user, expires_at: 6.days.from_now, created_at: 1.month.ago) }

    context 'when no new token was created after notification for recent expiring token started' do
      it_behaves_like 'rotation required'
    end

    context 'when token was created after notification for recent expiring token started' do
      before do
        create(:personal_access_token, user: user, created_at: recent_expiring_pat.expires_at - 2.days)
      end

      it_behaves_like 'rotation NOT required'
    end

    context 'with multiple expiring tokens' do
      let_it_be(:expiring_pat1) { create(:personal_access_token, expires_at: 4.days.ago, user: user, created_at: 1.month.ago) }

      context 'when no new token was created after notification for expiring token started' do
        it_behaves_like 'rotation required'
      end

      context 'when new token was created after notification for ONLY first expiring token started' do
        before do
          create(:personal_access_token, user: user, created_at: expiring_pat1.expires_at - 1.day)
        end

        it_behaves_like 'rotation required'
      end

      context 'when new token was created after notification for most recent expiring token started' do
        before do
          create(:personal_access_token, user: user, created_at: recent_expiring_pat.expires_at - 1.day)
        end

        it_behaves_like 'rotation NOT required'
      end
    end

    context 'For user with no PATs' do
      subject { described_class.new(no_pat_user).expiring_soon? }

      it_behaves_like 'rotation NOT required'
    end
  end
end
