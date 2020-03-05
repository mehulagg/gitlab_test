# frozen_string_literal: true

require 'spec_helper'

describe 'Using WebAuthn Devices for Authentication', :js do
  def manage_two_factor_authentication
    click_on 'Manage two-factor authentication'
    expect(page).to have_content('Set up new WebAuthn device')
    wait_for_requests
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

  describe 'registration' do
    let(:user) { create(:user) }

    before do
      gitlab_sign_in(user)
      user.update_attribute(:otp_required_for_login, true)
    end

    describe 'when 2FA via OTP is disabled' do
      before do
        user.update_attribute(:otp_required_for_login, false)
      end

      it 'does not allow registering a new device' do
        visit profile_account_path
        click_on 'Enable two-factor authentication'

        expect(page).to have_button('Set up new WebAuthn device', disabled: true)
      end
    end

    describe 'when 2FA via OTP is enabled' do
      it 'allows registering a new device with a name' do
        visit profile_account_path
        manage_two_factor_authentication
        expect(page).to have_content('You\'ve already enabled two-factor authentication using one time password authenticators')

        webauthn_device = register_webauthn_device

        expect(page).to have_content(webauthn_device.name)
        expect(page).to have_content('Your WebAuthn device was registered')
      end

      it 'allows registering more than one device' do
        visit profile_account_path

        # First device
        manage_two_factor_authentication
        first_device = register_webauthn_device
        expect(page).to have_content('Your WebAuthn device was registered')

        # Second device
        second_device = register_webauthn_device(name: 'My other device')
        expect(page).to have_content('Your WebAuthn device was registered')

        expect(page).to have_content(first_device.name)
        expect(page).to have_content(second_device.name)
        expect(WebauthnRegistration.count).to eq(2)
      end

      it 'allows deleting a device' do
        visit profile_account_path
        manage_two_factor_authentication
        expect(page).to have_content('You\'ve already enabled two-factor authentication using one time password authenticators')

        first_webauthn_device = register_webauthn_device
        second_webauthn_device = register_webauthn_device(name: 'My other device')

        expect(page).to have_content(first_webauthn_device.name)
        expect(page).to have_content(second_webauthn_device.name)

        accept_confirm { click_on 'Delete', match: :first }

        expect(page).to have_content('Successfully deleted')
        expect(page.body).to have_content(first_webauthn_device.name)
        expect(page.body).not_to have_content(second_webauthn_device.name)
      end
    end

    it 'allows the same device to be registered for multiple users' do
      # First user
      visit profile_account_path
      manage_two_factor_authentication
      webauthn_device = register_webauthn_device
      expect(page).to have_content('Your WebAuthn device was registered')
      gitlab_sign_out

      # Second user
      user = gitlab_sign_in(:user)
      user.update_attribute(:otp_required_for_login, true)
      visit profile_account_path
      manage_two_factor_authentication
      register_webauthn_device(webauthn_device, name: 'My other device')
      expect(page).to have_content('Your WebAuthn device was registered')

      expect(WebauthnRegistration.count).to eq(2)
    end

    context 'when there are form errors' do
      mock_register_js = <<~JS
        const mockResponse = {
          type: 'public-key',
          id: '',
          rawId: '',
          response: {
            clientDataJSON: '',
            attestationObject: '',
          },
          getClientExtensionResults: () => {},
        };
        navigator.credentials.create = function(_) {return Promise.resolve(mockResponse);}
      JS

      it 'doesn\'t register the device if there are errors' do
        visit profile_account_path
        manage_two_factor_authentication

        # Have the "webauthn device" respond with bad data
        page.execute_script(mock_register_js)
        click_on 'Set up new WebAuthn device'
        expect(page).to have_content('Your device was successfully set up')
        click_on 'Register WebAuthn device'

        expect(WebauthnRegistration.count).to eq(0)
        expect(page).to have_content('The form contains the following error')
        expect(page).to have_content('did not send a valid JSON response')
      end

      it 'allows retrying registration' do
        visit profile_account_path
        manage_two_factor_authentication

        # Failed registration
        page.execute_script(mock_register_js)
        click_on 'Set up new WebAuthn device'
        expect(page).to have_content('Your device was successfully set up')
        click_on 'Register WebAuthn device'
        expect(page).to have_content('The form contains the following error')

        # Successful registration
        register_webauthn_device

        expect(page).to have_content('Your WebAuthn device was registered')
        expect(WebauthnRegistration.count).to eq(1)
      end
    end
  end

  describe 'authentication' do
    let(:user) { create(:user) }

    before do
      # Register and logout
      gitlab_sign_in(user)
      user.update_attribute(:otp_required_for_login, true)
      visit profile_account_path
      manage_two_factor_authentication
      @webauthn_device = register_webauthn_device
      gitlab_sign_out
    end

    describe 'when 2FA via OTP is disabled' do
      it 'allows logging in with the WebAuthn device' do
        user.update_attribute(:otp_required_for_login, false)
        gitlab_sign_in(user)

        @webauthn_device.respond_to_webauthn_authentication

        expect(page).to have_css('.sign-out-link', visible: false)
      end
    end

    describe 'when 2FA via OTP is enabled' do
      it 'allows logging in with the WebAuthn device' do
        user.update_attribute(:otp_required_for_login, true)
        gitlab_sign_in(user)

        @webauthn_device.respond_to_webauthn_authentication

        expect(page).to have_css('.sign-out-link', visible: false)
      end
    end

    describe 'when a given WebAuthn device has already been registered by another user' do
      describe 'but not the current user' do
        it 'does not allow logging in with that particular device' do
          # Register current user with the different WebAuthn device
          current_user = gitlab_sign_in(:user)
          current_user.update_attribute(:otp_required_for_login, true)
          visit profile_account_path
          manage_two_factor_authentication
          register_webauthn_device(name: 'My other device')
          gitlab_sign_out

          # Try authenticating user with the old WebAuthn device
          gitlab_sign_in(current_user)
          @webauthn_device.respond_to_webauthn_authentication
          expect(page).to have_content('Authentication via WebAuthn device failed')
        end
      end

      describe "and also the current user" do
        # TODO Uncomment once WebAuthn::FakeClient supports passing credential options
        # (especially allow_credentials, as this is needed to specify which credential the
        # fake client should use. Currently, the first credential is always used).
        # There is an issue open for this: https://github.com/cedarcode/webauthn-ruby/issues/259

        it "allows logging in with that particular device" do
          pending("support for passing credential options in FakeClient")
          # Register current user with the same WebAuthn device
          current_user = gitlab_sign_in(:user)
          current_user.update_attribute(:otp_required_for_login, true)
          visit profile_account_path
          manage_two_factor_authentication
          register_webauthn_device(@webauthn_device)
          gitlab_sign_out

          # Try authenticating user with the same WebAuthn device
          gitlab_sign_in(current_user)
          @webauthn_device.respond_to_webauthn_authentication

          expect(page).to have_css('.sign-out-link', visible: false)
        end
      end
    end

    describe 'when a given WebAuthn device has not been registered' do
      it 'does not allow logging in with that particular device' do
        unregistered_device = FakeWebauthnDevice.new(page, 'My device')
        gitlab_sign_in(user)
        unregistered_device.respond_to_webauthn_authentication

        expect(page).to have_content('Authentication via WebAuthn device failed')
      end
    end

    describe 'when more than one device has been registered by the same user' do
      it 'allows logging in with either device' do
        # Register first device
        user = gitlab_sign_in(:user)
        user.update_attribute(:otp_required_for_login, true)
        visit profile_two_factor_auth_path
        expect(page).to have_content('Your WebAuthn device needs to be set up.')
        first_device = register_webauthn_device

        # Register second device
        visit profile_two_factor_auth_path
        expect(page).to have_content('Your WebAuthn device needs to be set up.')
        second_device = register_webauthn_device(name: 'My other device')
        gitlab_sign_out

        # Authenticate as both devices
        [first_device, second_device].each do |device|
          gitlab_sign_in(user)
          # register_webauthn_device(device)
          device.respond_to_webauthn_authentication

          expect(page).to have_css('.sign-out-link', visible: false)

          gitlab_sign_out
        end
      end
    end
  end

  describe 'u2f migration' do
    let(:user) { create(:user) }
    let(:challenge) { 'abc' }

    before do
      gitlab_sign_in(user)
      user.update_attribute(:otp_required_for_login, true)
      visit profile_account_path
      manage_two_factor_authentication

      app_id = page.evaluate_script('gon.webauthn.app_id')
      @u2f_device = U2F::FakeU2F.new(app_id)
      u2f = U2F::U2F.new(app_id)
      register_response_json = @u2f_device.register_response(challenge)
      register_response = U2F::RegisterResponse.load_from_json(register_response_json)
      registration_data = u2f.register!(challenge, register_response)
      registration = U2fRegistration.new(
        certificate: registration_data.certificate,
        key_handle: registration_data.key_handle,
        public_key: registration_data.public_key,
        counter: 0,
        user: user,
        name: 'u2f reg'
      )
      registration.save!

      @webauthn_device = FakeWebauthnDevice.new(page, 'name')
      @webauthn_device.add_credential(app_id, @u2f_device.key_handle_raw, @u2f_device.send(:origin_key))
      gitlab_sign_out
    end

    it 'allows logging in with old u2f registration' do
      gitlab_sign_in(user)

      @webauthn_device.respond_to_webauthn_authentication

      expect(page).to have_css('.sign-out-link', visible: false)
      expect(user.webauthn_registrations.length).to be(0)
    end
  end

  describe 'fallback code authentication' do
    let(:user) { create(:user) }

    def assert_fallback_ui(page)
      expect(page).to have_button('Verify code')
      expect(page).to have_css('#user_otp_attempt')
      expect(page).not_to have_link('Sign in via 2FA code')
      expect(page).not_to have_css('#js-authenticate-webauthn')
    end

    before do
      # Register and logout
      gitlab_sign_in(user)
      user.update_attribute(:otp_required_for_login, true)
      visit profile_account_path
    end

    describe 'when no webauthn device is registered' do
      before do
        gitlab_sign_out
        gitlab_sign_in(user)
      end

      it 'shows the fallback otp code UI' do
        assert_fallback_ui(page)
      end
    end

    describe 'when a webauthn device is registered' do
      before do
        manage_two_factor_authentication
        @webauthn_device = register_webauthn_device
        gitlab_sign_out
        gitlab_sign_in(user)
      end

      it 'provides a button that shows the fallback otp code UI' do
        expect(page).to have_link('Sign in via 2FA code')

        click_link('Sign in via 2FA code')

        assert_fallback_ui(page)
      end
    end
  end
end
