# frozen_string_literal: true

module Webauthn
  class AuthenticateService < BaseService
    def initialize(user, device_response, challenge, app_id)
      @user = user
      @device_response = device_response
      @challenge = challenge
      @app_id = app_id
    end

    def execute
      parsed_device_response = JSON.parse(@device_response)

      # appid is set for legacy U2F devices

      rp_id = @app_id

      unless parsed_device_response['clientExtensionResults'] && parsed_device_response['clientExtensionResults']['appid']
        rp_id = URI(@app_id).host
      end

      webauthn_credential = WebAuthn::Credential.from_get(parsed_device_response)
      encoded_raw_id = Base64.strict_encode64(webauthn_credential.raw_id)
      stored_webauthn_credential = @user.webauthn_registrations.find_by_external_id(encoded_raw_id)
      u2f_registration = nil

      unless stored_webauthn_credential
        stored_webauthn_credential = @user.converted_webauthn_registrations.find { |migrated_credential| migrated_credential.external_id == encoded_raw_id }
        u2f_registration = @user.u2f_registrations.find { |u2f_reg| Base64.urlsafe_decode64(u2f_reg.key_handle) == webauthn_credential.raw_id }
      end

      encoder = WebAuthn.configuration.encoder

      if stored_webauthn_credential &&
          validate_webauthn_credential(webauthn_credential) &&
          verify_webauthn_credential(webauthn_credential, stored_webauthn_credential, @challenge, encoder, rp_id, @app_id)

        if u2f_registration
          u2f_registration.update!(counter: webauthn_credential.sign_count)
        else
          stored_webauthn_credential.update!(counter: webauthn_credential.sign_count)
        end

        return true
      end

      false
    rescue JSON::ParserError, WebAuthn::SignCountVerificationError, WebAuthn::Error
      false
    end

    ##
    # Validates that webauthn_credential is syntactically valid
    #
    # duplicated from WebAuthn::PublicKeyCredential#verify
    # which can't be used here as we need to call WebAuthn::AuthenticatorAssertionResponse#verify instead
    # (which is done in #verify_webauthn_credential)
    def validate_webauthn_credential(webauthn_credential)
      webauthn_credential.type == WebAuthn::TYPE_PUBLIC_KEY &&
          webauthn_credential.raw_id && webauthn_credential.id &&
          webauthn_credential.raw_id == WebAuthn.standard_encoder.decode(webauthn_credential.id)
    end

    ##
    # Verifies that webauthn_credential matches stored_credential with the given challenge
    #
    def verify_webauthn_credential(webauthn_credential, stored_credential, challenge, encoder, rp_id, app_id)
      webauthn_credential.response.verify(
        encoder.decode(challenge),
          app_id,
          public_key: encoder.decode(stored_credential.public_key),
          sign_count: stored_credential.counter,
          rp_id: rp_id)
    end
  end
end
