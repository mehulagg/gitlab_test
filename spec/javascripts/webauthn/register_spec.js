import $ from 'jquery';
import WebAuthnRegister from '~/webauthn/register';
import MockWebAuthnDevice from './mock_webauthn_device';
import { flushPromises } from './util';

describe('WebAuthnRegister', function() {
  preloadFixtures('webauthn/register.html');

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

  beforeEach(() => {
    loadFixtures('webauthn/register.html');
    this.webAuthnDevice = new MockWebAuthnDevice();
    this.container = $('#js-register-webauthn');
    this.component = new WebAuthnRegister(this.container, {
      options: {
        rp: '',
        user: {
          id: '',
          name: '',
          displayName: '',
        },
        challenge: '',
        pubKeyCredParams: '',
      },
    });
    this.component.start();
  });

  it('allows registering a WebAuthn device', () => {
    const setupButton = this.container.find('#js-setup-webauthn-device');

    expect(setupButton.text()).toBe('Set up new WebAuthn device');
    setupButton.trigger('click');
    const inProgressMessage = this.container.children('p');

    expect(inProgressMessage.text()).toContain('Trying to communicate with your device');
    return flushPromises()
      .then(() => {
        this.webAuthnDevice.respondToRegisterRequest(mockResponse);
        return flushPromises();
      })
      .then(() => {
        const registeredMessage = this.container.find('p');
        const deviceResponse = this.container.find('#js-device-response');

        expect(registeredMessage.text()).toContain('Your device was successfully set up!');
        expect(deviceResponse.val()).toBe(JSON.stringify(mockResponse));
      });
  });

  describe('errors', () => {
    const testErrorMessage = (error, expectedErrorMessage) => {
      const setupButton = this.container.find('#js-setup-webauthn-device');
      setupButton.trigger('click');
      // eslint-disable-next-line promise/no-promise-in-callback
      return flushPromises()
        .then(() => {
          this.webAuthnDevice.rejectRegisterRequest(error);
          return flushPromises();
        })
        .then(() => {
          const errorMessage = this.container.find('p');

          expect(errorMessage.text()).toContain(expectedErrorMessage);
        });
    };

    it('displays an error message for NotSupportedError', () =>
      testErrorMessage(
        new DOMException('', 'NotSupportedError'),
        'Your device is not compatible with GitLab',
      ));

    it('displays an error message for other errors', () =>
      testErrorMessage(
        new DOMException('', 'NotAllowedError'),
        'There was a problem communicating with your device',
      ));

    it('allows retrying registration after an error', () => {
      let setupButton = this.container.find('#js-setup-webauthn-device');
      setupButton.trigger('click');
      return flushPromises()
        .then(() => {
          this.webAuthnDevice.respondToRegisterRequest({
            errorCode: 'error!',
          });
          return flushPromises();
        })
        .then(() => {
          const retryButton = this.container.find('.js-webauthn-try-again');
          retryButton.trigger('click');
          setupButton = this.container.find('#js-setup-webauthn-device');
          setupButton.trigger('click');
          this.webAuthnDevice.respondToRegisterRequest(mockResponse);

          return flushPromises();
        })
        .then(() => {
          const registeredMessage = this.container.find('p');

          expect(registeredMessage.text()).toContain('Your device was successfully set up!');
        });
    });
  });
});
