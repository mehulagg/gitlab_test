# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Admin::Emails', :clean_gitlab_redis_shared_state do
  include ExclusiveLeaseHelpers

  before do
    sign_in(create(:admin))
  end

  context 'when `send_emails_from_admin_area` feature is not licensed' do
    before do
      stub_licensed_features(send_emails_from_admin_area: false)
    end

    it 'returns 404' do
      visit admin_email_path

      expect(page.status_code).to eq(404)
    end
  end

  context 'when `send_emails_from_admin_area` feature is licensed' do
    let(:rate_limited_alert) do
      'An email notification was recently sent from the admin panel. '\
      'Please wait 10 minutes before attempting to send another message.'
    end

    let(:submit_button) { find('input[type="submit"]') }

    before do
      stub_licensed_features(send_emails_from_admin_area: true)
    end

    context 'when emails from admin area are not rate limited' do
      it 'does not show the waiting period alert'\
        'and the submit button is in enabled state' do
        visit admin_email_path

        expect(page).not_to have_content(rate_limited_alert)
        expect(submit_button.disabled?).to eq(false)
      end
    end

    context 'when emails from admin area are rate limited' do
      let(:lease_key) { Admin::EmailService::LEASE_KEY }
      let(:timeout) { Admin::EmailService::DEFAULT_LEASE_TIMEOUT }

      before do
        allow(Gitlab::ExclusiveLease).to receive(:new).and_call_original
        stub_exclusive_lease(lease_key, timeout: timeout)
      end

      it 'shows the waiting period alert'\
        'and the submit button is in disabled state' do
        visit admin_email_path

        expect(page).to have_content(rate_limited_alert)
        expect(submit_button.disabled?).to eq(true)
      end
    end
  end
end
