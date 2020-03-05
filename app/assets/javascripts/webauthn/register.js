import WebAuthnError from './error';
import WebAuthnFlow from './flow';
import { supported, convertCreateParams, convertCreateResponse } from './util';

// Register WebAuthn devices for users to authenticate with.
//
// State Flow #1: setup -> in_progress -> registered -> POST to server
// State Flow #2: setup -> in_progress -> error -> setup
export default class WebAuthnRegister {
  constructor(container, webauthnParams) {
    this.container = container;
    this.renderNotSupported = this.renderNotSupported.bind(this);
    this.renderRegistered = this.renderRegistered.bind(this);
    this.renderInProgress = this.renderInProgress.bind(this);
    this.renderSetup = this.renderSetup.bind(this);
    this.register = this.register.bind(this);
    this.start = this.start.bind(this);
    this.webauthnOptions = convertCreateParams(webauthnParams.options);

    this.flow = new WebAuthnFlow(container, {
      notSupported: '#js-register-webauthn-not-supported',
      setup: '#js-register-webauthn-setup',
      inProgress: '#js-register-webauthn-in-progress',
      error: '#js-register-webauthn-error',
      registered: '#js-register-webauthn-registered',
    });

    this.container.on('click', '.js-webauthn-try-again', this.renderInProgress);
  }

  start() {
    if (!supported()) {
      this.renderNotSupported();
    } else {
      this.renderSetup();
    }
  }

  register() {
    navigator.credentials
      .create({
        publicKey: this.webauthnOptions,
      })
      .then(cred => this.renderRegistered(JSON.stringify(convertCreateResponse(cred))))
      .catch(err => this.flow.renderError(new WebAuthnError(err, 'register')));
  }

  renderSetup() {
    this.flow.renderTemplate('setup');
    this.container.find('#js-setup-webauthn-device').on('click', this.renderInProgress);
  }

  renderInProgress() {
    this.flow.renderTemplate('inProgress');
    return this.register();
  }

  renderRegistered(deviceResponse) {
    this.flow.renderTemplate('registered');
    // Prefer to do this instead of interpolating using Underscore templates
    // because of JSON escaping issues.
    return this.container.find('#js-device-response').val(deviceResponse);
  }

  renderNotSupported() {
    return this.flow.renderTemplate('notSupported');
  }
}
