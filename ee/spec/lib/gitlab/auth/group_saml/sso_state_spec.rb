# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Auth::GroupSaml::SsoState do
  let(:user) { double(:user, id: 2) }
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

  describe '#session_active?' do
    it 'gets the current sign in state' do
      current_state = double

      Gitlab::Session.with_session(active_group_sso_sign_ins: { saml_provider_id => current_state }) do
        expect(subject.session_active?).to eq current_state
      end
    end
  end

  describe '#active?' do
    let(:current_sign_in) { double }
    let(:sign_ins) { { saml_provider_id => current_sign_in } }

    context 'with an active session' do
      around do |example|
        Gitlab::Session.with_session(active_group_sso_sign_ins: sign_ins) do
          example.run
        end
      end

      it 'uses the active session' do
        expect(subject.active?(user)).to eq(current_sign_in)
      end
    end

    context 'without an active session' do
      it 'uses redis background sessions' do
        expect(subject).to receive(:background_sso_session?).with(user)

        subject.active?(user)
      end
    end
  end

  describe '#background_sso_session?', :clean_gitlab_redis_shared_state do
    context 'with a valid background redis session' do
      let(:session_id) { '6919a6f1bb119dd7396fadc38fd18d0d' }
      let(:stored_session) { { 'active_group_sso_sign_ins' => { saml_provider_id => 1.day.ago } } }

      before do
        Gitlab::Redis::SharedState.with do |redis|
          redis.set("session:gitlab:#{session_id}", Marshal.dump(stored_session))
          redis.sadd("session:lookup:user:gitlab:#{user.id}", [session_id])
        end
      end

      it { is_expected.to be_background_sso_session(user) }
    end

    context 'without a valid background sesssion' do
      it { is_expected.not_to be_background_sso_session(user) }
    end
  end
end
