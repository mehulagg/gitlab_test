# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Auth::KeyStatusChecker do
  let_it_be(:never_expires_key) { build(:personal_key, expires_at: nil) }
  let_it_be(:expired_key) { build(:personal_key, expires_at: 3.days.ago) }
  let_it_be(:expiring_soon_key) { build(:personal_key, expires_at: 3.days.from_now) }
  let_it_be(:expires_in_future_key) { build(:personal_key, expires_at: 14.days.from_now) }

  let(:key_status_checker) { described_class.new(key) }

  describe '#active?' do
    subject { key_status_checker.active? }

    context 'for an expired key' do
      let(:key) { expired_key }

      it { is_expected.to be_falsey }
    end

    context 'for a key expiring in the next 7 days' do
      let(:key) { expiring_soon_key }

      it { is_expected.to be_falsey }
    end

    context 'for a key expiring after the next 7 days' do
      let(:key) { expires_in_future_key }

      it { is_expected.to be_truthy }
    end

    context 'for a key that never expires' do
      let(:key) { never_expires_key }

      it { is_expected.to be_truthy }
    end
  end

  describe '#message' do
    subject { key_status_checker.message }

    context 'for an expired key' do
      let(:key) { expired_key }

      it { is_expected.to match /has expired/ }
    end

    context 'for a key expiring in the next 7 days' do
      let(:key) { expiring_soon_key }

      it { is_expected.to match /expiring soon/ }
    end

    context 'for a key expiring after the next 7 days' do
      let(:key) { expires_in_future_key }

      it { is_expected.to match /active/ }
    end

    context 'for a key that never expires' do
      let(:key) { never_expires_key }

      it { is_expected.to match /active/ }
    end
  end
end
