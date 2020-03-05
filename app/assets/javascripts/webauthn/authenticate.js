import WebAuthnError from './error';
import WebAuthnFlow from './flow';
import { supported, convertGetParams, convertGetResponse } from './util';

// Authenticate WebAuthn devices for users to authenticate with.
//
// State Flow #1: setup -> in_progress -> authenticated -> POST to server
// State Flow #2: setup -> in_progress -> error -> setup
export default class WebAuthnAuthenticate {
  constructor(container, form, webauthnParams, fallbackButton, fallbackUI) {
    this.container = container;
    this.webauthnParams = convertGetParams(JSON.parse(webauthnParams.options));
    this.renderAuthenticated = this.renderAuthenticated.bind(this);
    this.renderInProgress = this.renderInProgress.bind(this);
    this.authenticate = this.authenticate.bind(this);
    this.start = this.start.bind(this);
    this.form = form;
    this.fallbackButton = fallbackButton;
    this.fallbackUI = fallbackUI;
    if (this.fallbackButton) {
      this.fallbackButton.addEventListener('click', this.switchToFallbackUI.bind(this));
    }

    this.flow = new WebAuthnFlow(container, {
      setup: '#js-authenticate-webauthn-setup',
      inProgress: '#js-authenticate-webauthn-in-progress',
      error: '#js-authenticate-webauthn-error',
      authenticated: '#js-authenticate-webauthn-authenticated',
    });

    this.container.on('click', '.js-webauthn-try-again', this.renderInProgress);
  }

  start() {
    if (!supported()) {
      this.switchToFallbackUI();
    } else {
      this.renderInProgress();
    }
  }

  authenticate() {
    return navigator.credentials
      .get({ publicKey: this.webauthnParams })
      .then(resp => {
        const convertedResponse = convertGetResponse(resp);
        this.renderAuthenticated(JSON.stringify(convertedResponse));
      })
      .catch(err => {
        this.flow.renderError(new WebAuthnError(err, 'authenticate'));
      });
  }

  renderInProgress() {
    this.flow.renderTemplate('inProgress');
    this.authenticate();
  }

  renderAuthenticated(deviceResponse) {
    this.flow.renderTemplate('authenticated');
    const container = this.container[0];
    container.querySelector('#js-device-response').value = deviceResponse;
    container.querySelector(this.form).submit();
    this.fallbackButton.classList.add('hidden');
  }

  switchToFallbackUI() {
    this.fallbackButton.classList.add('hidden');
    this.container[0].classList.add('hidden');
    this.fallbackUI.classList.remove('hidden');
  }
}
