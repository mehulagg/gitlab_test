import $ from 'jquery';
import WebAuthnAuthenticate from '~/webauthn/authenticate';
import MockWebAuthnDevice from './mock_webauthn_device';
import { flushPromises } from './util';

describe('WebAuthnAuthenticate', function() {
  preloadFixtures('webauthn/authenticate.html');

  beforeEach(() => {
    loadFixtures('webauthn/authenticate.html');
    this.webAuthnDevice = new MockWebAuthnDevice();
    this.container = $('#js-authenticate-webauthn');
    this.component = new WebAuthnAuthenticate(
      this.container,
      '#js-login-webauthn-form',
      {
        options:
          // we need some valid base64 for base64UrlToBuffer
          // so we use "YQ==" = base64("a")
          '{"challenge":"YQ==","timeout":120000,"allowCredentials":[{"type":"public-key","id":"YQ=="},{"type":"public-key","id":"YQ=="}],"userVerification":"discouraged"}',
      },
      document.querySelector('#js-login-2fa-device'),
      document.querySelector('.js-2fa-form'),
    );
  });

  describe('with webauthn unavailable', () => {
    beforeEach(() => {
      spyOn(this.component, 'switchToFallbackUI');
      this.oldgetcredentials = window.navigator.credentials.get;
      window.navigator.credentials.get = null;
    });

    afterEach(() => {
      window.navigator.credentials.get = this.oldgetcredentials;
    });

    it('falls back to normal 2fa', () => {
      this.component.start();

      expect(this.component.switchToFallbackUI).toHaveBeenCalled();
    });
  });

  describe('with webauthn available', () => {
    beforeEach(() => {
      // bypass automatic form submission within renderAuthenticated
      spyOn(this.component, 'renderAuthenticated').and.returnValue(true);
      this.webAuthnDevice = new MockWebAuthnDevice();
      this.component.start();
    });

    const mockResponse = {
      type: 'public-key',
      id: '',
      rawId: '',
      response: { clientDataJSON: '', authenticatorData: '', signature: '', userHandle: '' },
      getClientExtensionResults: () => {},
    };

    it('allows authenticating via a WebAuthn device', () => {
      const inProgressMessage = this.container.find('p');

      expect(inProgressMessage.text()).toContain('Trying to communicate with your device');
      this.webAuthnDevice.respondToAuthenticateRequest(mockResponse);
      return flushPromises().then(() => {
        expect(this.component.renderAuthenticated).toHaveBeenCalledWith(
          JSON.stringify(mockResponse),
        );
      });
    });

    describe('errors', () => {
      it('displays an error message', () => {
        this.webAuthnDevice.rejectAuthenticateRequest(new DOMException());
        return flushPromises().then(() => {
          const errorMessage = this.container.find('p');

          expect(errorMessage.text()).toContain(
            'There was a problem communicating with your device',
          );
        });
      });

      return it('allows retrying authentication after an error', () => {
        this.webAuthnDevice.rejectAuthenticateRequest(new DOMException());
        return flushPromises()
          .then(() => {
            const retryButton = this.container.find('.js-webauthn-try-again');
            retryButton.trigger('click');
            this.webAuthnDevice.respondToAuthenticateRequest(mockResponse);
            return flushPromises();
          })
          .then(() => {
            expect(this.component.renderAuthenticated).toHaveBeenCalledWith(
              JSON.stringify(mockResponse),
            );
          });
      });
    });
  });
});
