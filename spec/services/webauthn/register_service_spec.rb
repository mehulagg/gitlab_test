# frozen_string_literal: true

require 'spec_helper'

describe Webauthn::RegisterService do
  let(:client) { WebAuthn::FakeClient.new(actual_origin) }
  let(:user) { create(:user) }
  let(:challenge) { Base64.urlsafe_encode64(SecureRandom.random_bytes(32)) }

  let(:appid) { 'http://localhost' }
  let(:origin) { 'http://localhost' }
  let(:actual_origin) { origin }

  before do
    WebAuthn.configuration.origin = origin
  end

  describe '#execute' do
    it 'returns a registration if challenge matches' do
      create_result = client.create(challenge: challenge)
      webauthn_credential = WebAuthn::Credential.from_create(create_result)

      params = { device_response: create_result.to_json, name: 'abc' }
      service = Webauthn::RegisterService.new(user, params, challenge)

      registration = service.execute
      expect(registration.external_id).to eq(Base64.strict_encode64(webauthn_credential.raw_id))
      expect(registration.errors.size).to eq(0)
    end

    it 'returns an error if challenge does not match' do
      create_result = client.create(challenge: Base64.urlsafe_encode64(SecureRandom.random_bytes(16)))

      params = { device_response: create_result.to_json, name: 'abc' }
      service = Webauthn::RegisterService.new(user, params, challenge)

      registration = service.execute
      expect(registration.errors.size).to eq(1)
    end
  end
end
