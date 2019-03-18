# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Auth::GroupSaml::SessionEnforcer do
  let(:saml_provider) { build_stubbed(:saml_provider, enforced_sso: true) }
  let(:session) { Hash.new }

  subject { described_class.new(session, saml_provider) }

  describe '#update_session' do
    it 'stores that a session is active for the given provider' do
      expect{ subject.update_session }.to change { session[:group_saml_sign_ins] }
    end

    it 'stores the current time for later comparison', freeze: true do
      subject.update_session

      expect(session[:group_saml_sign_ins][saml_provider.id]).to eq DateTime.now
    end
  end

  describe '#active_session?' do
    it 'returns false if nothing has been stored' do
      expect(subject).not_to be_active_session
    end

    it 'returns true if a sign in has been recorded' do
      subject.update_session

      expect(subject).to be_active_session
    end
  end

  describe '#allows_access?' do
    it 'allows access when saml_provider is nil' do
      subject = described_class.new({}, nil)

      expect(subject).not_to be_access_restricted
    end

    it 'allows access when saml_provider is disabled' do
      saml_provider.update!(enabled: false)

      expect(subject).not_to be_access_restricted
    end

    it 'allows access when sso enforcement is disabled' do
      saml_provider.update!(enforced_sso: false)

      expect(subject).not_to be_access_restricted
    end

    it 'allows access when the sso enforcement feature is disabled' do
      stub_feature_flags(enforced_sso: { enabled: false, thing: saml_provider.group })

      expect(subject).not_to be_access_restricted
    end

    it 'prevents access when sso enforcement active but there is no session' do
      expect(subject).to be_access_restricted
    end

    it 'allows access when sso is enforced but a saml session is active' do
      subject.update_session

      expect(subject).not_to be_access_restricted
    end
  end

  describe '.clear' do
    it 'clears active session information for all SAML providers' do
      session = { :group_saml_sign_ins => { saml_provider.id => DateTime.now } }

      described_class.clear(session)

      expect(session).to eq({})
    end
  end
end
