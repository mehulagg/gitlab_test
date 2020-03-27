# frozen_string_literal: true
# These helpers allow you to manage and register
# U2F and WebAuthn devices
#
# Usage:
#   describe "..." do
#   include Spec::Support::Helpers::Features::TwoFactorHelpers
#     ...
#
#   manage_two_factor_authentication('WebAuthn')
#
module Spec
  module Support
    module Helpers
      module Features
        module TwoFactorHelpers
          def manage_two_factor_authentication(device_type)
            click_on 'Manage two-factor authentication'
            expect(page).to have_content("Set up new #{device_type} device")
            wait_for_requests
          end

          def register_u2f_device(u2f_device = nil, name: 'My device')
            u2f_device ||= FakeU2fDevice.new(page, name)
            u2f_device.respond_to_u2f_registration
            click_on 'Set up new U2F device'
            expect(page).to have_content('Your device was successfully set up')
            fill_in "Pick a name", with: name
            click_on 'Register U2F device'
            u2f_device
          end

          def register_webauthn_device(webauthn_device = nil, name: 'My device')
            webauthn_device ||= FakeWebauthnDevice.new(page, name)
            webauthn_device.respond_to_webauthn_registration
            click_on 'Set up new WebAuthn device'
            expect(page).to have_content('Your device was successfully set up')
            fill_in 'Pick a name', with: name
            click_on 'Register WebAuthn device'
            webauthn_device
          end
        end
      end
    end
  end
end
