# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Auth::GroupSaml::BackgroundSsoState do
  let(:user) { double }

  subject { described_class.new(user) }

  describe '#all' do
    it 'returns SAML data from sessions' do
      saml_data = { 7 => double }
      sessions = [{ 'active_group_sso_sign_ins' => saml_data }]
      allow(ActiveSession).to receive(:list_sessions).and_return(sessions)

      expect(subject.all).to eq([saml_data])
    end

    it 'skips sessions which do not have SAML data' do
      sessions = [{ a: 1 }, { b: 2 }]
      allow(ActiveSession).to receive(:list_sessions).and_return(sessions)

      expect(subject.all).to eq([])
    end
  end

  describe '#most_recent' do
    let(:saml_datetime) { double }
    let(:saml_provider_id) { 7 }
    let(:saml_data) { { saml_provider_id => saml_datetime } }
    let(:session_with_saml) { { 'active_group_sso_sign_ins' => saml_data } }

    it 'returns the date a saml provider was used to sign in' do
      allow(ActiveSession).to receive(:list_sessions).and_return([session_with_saml])

      expect(subject.most_recent(saml_provider_id)).to eq(saml_datetime)
    end

    it 'looks up the most recent SAML session for a provider' do
      latest_date = 1.day.ago
      oldest_date = 1.month.ago

      saml_sessions = [{ saml_provider_id => oldest_date }, { saml_provider_id => latest_date }]
      allow(subject).to receive(:all).and_return(saml_sessions)

      expect(subject.most_recent(saml_provider_id)).to eq(latest_date)
    end

    it 'returns nil when the saml provider has no sessions' do
      allow(ActiveSession).to receive(:list_sessions).and_return([session_with_saml])

      expect(subject.most_recent(6)).to eq(nil)
    end

    it 'returns nil when there was no saml data' do
      sessions = [{ a: 1 }, { b: 2 }]
      allow(ActiveSession).to receive(:list_sessions).and_return(sessions)

      expect(subject.most_recent(saml_provider_id)).to eq(nil)
    end
  end
end
