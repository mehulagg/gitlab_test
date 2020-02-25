# frozen_string_literal: true

require 'spec_helper'

describe 'admin/sessions/two_factor.html.haml' do
  before do
    allow(view).to receive(:current_user).and_return(user)
    allow(view).to receive(:resource).and_return(user)
  end

  context 'user has no two factor auth' do
    let(:user) { create(:admin) }

    it 'shows tab' do
      render

      expect(rendered).not_to have_css('.login-box')
    end
  end

  context 'user has otp active' do
    let(:user) { create(:admin, :two_factor) }

    it 'shows enter otp form' do
      render

      expect(rendered).to have_css('#login-pane.active')
      expect(rendered).to have_selector('input[name="user[otp_attempt]"]')
    end
  end

  context 'user has u2f active' do
    let(:user) { create(:admin, :two_factor_via_u2f) }

    it 'shows enter u2f form' do
      render

      expect(rendered).to have_css('#js-login-2fa-device.btn')
    end
  end
end
