# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Registrations::WelcomeController do
  let_it_be(:user) { create(:user) }

  describe '#welcome' do
    subject { get :show }

    context '2FA is required from group' do
      before do
        user = create(:user, require_two_factor_authentication_from_group: true)
        sign_in(user)
      end

      it 'does not perform a redirect' do
        expect(subject).not_to redirect_to(profile_two_factor_auth_path)
      end
    end
  end

  describe '#update' do
    subject(:update_registration) do
      put :update, params: { user: { role: 'software_developer', setup_for_company: 'false' } }
    end

    before do
      sign_in(create(:user))
    end

    it 'sets flash message' do
      subject

      expect(flash[:notice]).to eq(I18n.t('devise.registrations.signed_up'))
    end
  end
end
