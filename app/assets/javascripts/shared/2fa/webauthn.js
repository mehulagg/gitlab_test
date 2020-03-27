import $ from 'jquery';
import WebAuthnAuthenticate from '~/webauthn/authenticate';

export default () => {
  if (!gon.webauthn) return;

  const webauthnAuthenticate = new WebAuthnAuthenticate(
    $('#js-authenticate-webauthn'),
    '#js-login-webauthn-form',
    gon.webauthn,
    document.querySelector('#js-login-2fa-device'),
    document.querySelector('.js-2fa-form'),
  );
  webauthnAuthenticate.start();
  // needed in rspec (FakeWebauthnDevice) to fake authentication
  gl.webauthnAuthenticate = webauthnAuthenticate;
};
