import { __ } from '~/locale';

export default class WebAuthnError {
  constructor(error, flowType) {
    this.error = error;
    this.errorName = error.name || 'UnknownError';
    this.message = this.message.bind(this);
    this.httpsDisabled = window.location.protocol !== 'https:';
    this.flowType = flowType;
  }

  message() {
    if (this.error.name === 'NotSupportedError') {
      return __('Your device is not compatible with GitLab. Please try another device');
    } else if (this.error.name === 'InvalidStateError' && this.flowType === 'authenticate') {
      return __('This device has not been registered with us.');
    } else if (this.error.name === 'InvalidStateError' && this.flowType === 'register') {
      return __('This device has already been registered with us.');
    } else if (this.error.name === 'SecurityError' && this.httpsDisabled) {
      return __(
        'WebAuthn only works with HTTPS-enabled websites. Contact your administrator for more details.',
      );
    }

    return __('There was a problem communicating with your device.');
  }
}
