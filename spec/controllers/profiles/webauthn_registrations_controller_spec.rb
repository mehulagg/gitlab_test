# frozen_string_literal: true

require 'spec_helper'

describe Profiles::WebauthnRegistrationsController do
  let(:user) { create(:user, :two_factor_via_webauthn) }

  before do
    sign_in(user)
  end

  describe '#destroy' do
    it 'deletes the given webauthn registration' do
      registration_count = user.webauthn_registrations.count
      registration_to_delete = user.webauthn_registrations.first

      delete :destroy, params: { id: registration_to_delete.id }

      expect(response).to be_redirect
      expect(user.webauthn_registrations.count).to eq(registration_count - 1)
    end
  end
end
