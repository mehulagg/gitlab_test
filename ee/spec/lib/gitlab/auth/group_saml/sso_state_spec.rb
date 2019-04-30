# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Auth::GroupSaml::SsoState do
  let(:saml_provider_id) { 10 }

  subject { described_class.new(saml_provider_id) }

  describe '#update_active' do
    it 'updates the current sign in state' do
      Gitlab::Session.with_session({}) do
        new_state = double
        subject.update_active(new_state)

        expect(Gitlab::Session.current[:active_group_sso_sign_ins]).to eq({ saml_provider_id => new_state })
      end
    end
  end

  describe '#active?' do
    it 'gets the current sign in state' do
      current_state = double

      Gitlab::Session.with_session(active_group_sso_sign_ins: { saml_provider_id => current_state }) do
        expect(subject.active?).to eq current_state
      end
    end
  end

  describe '#background' do
    it 'finds sso state in other redis sessions'
    it 'picks the most recent state'
  end

  describe '#for_user' do
    let(:user) { double(:user) }
    let(:current_sign_in) { double }
    let(:sign_ins) { { saml_provider_id => current_sign_in } }

    context 'with an active session' do
      around do |example|
        Gitlab::Session.with_session(active_group_sso_sign_ins: sign_ins) do
          example.run
        end
      end

      it 'uses the active session' do
        expect(subject.for_user(user)).to eq(current_sign_in)
      end
    end

    context 'without an active session' do
      it 'uses redis background sessions' do
        expect(subject).to receive(:background).with(user)

        subject.for_user(user)
      end
    end
  end

  describe '.clear_active' do
    it 'resets the active sso state' do
      Gitlab::Session.with_session(active_group_sso_sign_ins: { 1 => double }) do
        described_class.clear_active

        expect(Gitlab::Session.current).to eq(active_group_sso_sign_ins: {})
      end
    end
  end
end
