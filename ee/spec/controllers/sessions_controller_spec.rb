# frozen_string_literal: true

require 'spec_helper'

describe SessionsController do
  include DeviseHelpers

  let(:user) { create(:user) }

  before do
    set_devise_mapping(context: @request)
  end

  context 'with SSO enforcement' do
    let(:saml_provider) { create(:saml_provider) }

    describe '#destroy' do
      before do
        sign_in(user)
      end

      it 'clears active SAML session' do
        Gitlab::Auth::GroupSaml::SessionEnforcer.new(session, saml_provider).update_session

        #TODO: recieve :clear with session where group_saml_sign_ins is set
        expect { get :destroy }.to change { session[:group_saml_sign_ins] }.to(nil)
      end
    end
  end
end
