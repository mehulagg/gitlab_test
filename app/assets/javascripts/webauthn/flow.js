import _ from 'underscore';

/**
 * Generic abstraction for WebAuthnFlows, especially for register / authenticate
 */
export default class WebAuthnFlow {
  constructor(container, templates) {
    this.container = container;
    this.templates = templates;

    this.renderTemplate = this.renderTemplate.bind(this);
    this.renderError = this.renderError.bind(this);
  }

  renderTemplate(name, params) {
    const templateString = document.querySelector(this.templates[name]).innerHTML;
    const template = _.template(templateString);
    return this.container.html(template(params));
  }

  renderError(error) {
    this.renderTemplate('error', {
      error_message: error.message(),
      error_name: error.errorName,
    });
  }
}
