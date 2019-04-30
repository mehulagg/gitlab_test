# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Auth::GroupSaml::SsoEnforcer do
  let(:saml_provider) { build_stubbed(:saml_provider, enforced_sso: true) }
  let(:session) { {} }

  around do |example|
    Gitlab::Session.with_session(session) do
      example.run
    end
  end

  subject { described_class.new(saml_provider) }

  describe '#update_session' do
    it 'stores that a session is active for the given provider' do
      expect { subject.update_session }.to change { session[:active_group_sso_sign_ins] }
    end

    it 'stores the current time for later comparison' do
      Timecop.freeze do
        subject.update_session

        expect(session[:active_group_sso_sign_ins][saml_provider.id]).to eq DateTime.now
      end
    end
  end

  describe '#active_session?' do
    let(:user) { double }

    it 'returns false if nothing has been stored' do
      expect(subject).not_to be_active_session(user)
    end

    it 'returns true if a sign in has been recorded' do
      subject.update_session

      expect(subject).to be_active_session(user)
    end

    context 'without an active session' do
      let(:session) { nil }

      it 'checks background session' do
        expect(subject.sso_state).to receive(:background_sso_session?).with(user)

        subject.active_session?(user)
      end

      it 'skips background session check when that feature is not enabled' do
        stub_feature_flags(enforced_sso_checks_background_session: false)

        expect(subject.sso_state).not_to receive(:background_sso_session?)

        subject.active_session?(user)
      end
    end
  end

  describe '#allows_access?' do
    let(:user) { double }

    it 'allows access when saml_provider is nil' do
      subject = described_class.new(nil)

      expect(subject).not_to be_access_restricted(user)
    end

    context 'when sso enforcement is disabled' do
      let(:saml_provider) { build_stubbed(:saml_provider, enforced_sso: false) }

      it 'allows access when sso enforcement is disabled' do
        expect(subject).not_to be_access_restricted(user)
      end
    end

    context 'when saml_provider is disabled' do
      let(:saml_provider) { build_stubbed(:saml_provider, enforced_sso: true, enabled: false) }

      it 'allows access when saml_provider is disabled' do
        expect(subject).not_to be_access_restricted(user)
      end
    end

    it 'allows access when the sso enforcement feature is disabled' do
      stub_feature_flags(enforced_sso: { enabled: false, thing: saml_provider.group })

      expect(subject).not_to be_access_restricted(user)
    end

    it 'prevents access when sso enforcement active but there is no session' do
      expect(subject).to be_access_restricted(user)
    end

    it 'allows access when sso is enforced but a saml session is active' do
      subject.update_session

      expect(subject).not_to be_access_restricted(user)
    end
  end
end
