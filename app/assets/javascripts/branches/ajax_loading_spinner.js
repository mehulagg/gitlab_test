export default class AjaxLoadingSpinner {
  static init() {
    const elements = document.querySelectorAll('.js-ajax-loading-spinner');

    elements.forEach(element => {
      element.addEventListener('ajax:beforeSend', AjaxLoadingSpinner.ajaxBeforeSend);
    });
  }

  static ajaxBeforeSend(e) {
    const button = e.target;
    const newButton = document.createElement('button');
    newButton.classList.add('btn', 'btn-default', 'disabled', 'gl-button');
    newButton.setAttribute('disabled', 'disabled');

    const spinner = document.createElement('span');
    spinner.classList.add('align-text-bottom', 'gl-spinner', 'gl-spinner-sm', 'gl-spinner-orange');
    newButton.appendChild(spinner);

    button.classList.add('hidden');
    button.parentNode.insertBefore(newButton, button.nextSibling);

    button.addEventListener(
      'ajax:error',
      () => {
        newButton.remove();
        button.classList.remove('hidden');
      },
      { once: true },
    );

    button.addEventListener(
      'ajax:success',
      () => {
        button.removeEventListener('ajax:beforeSend', AjaxLoadingSpinner.ajaxBeforeSend);
      },
      { once: true },
    );
  }
}
