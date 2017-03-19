/*= require vue */
/* global Vue */

(() => {
  window.gl = window.gl || {};
  window.gl.environmentsList = window.gl.environmentsList || {};

  window.gl.environmentsList.ExternalUrlComponent = Vue.component('external-url-component', {
    props: {
      externalUrl: {
        type: String,
        default: '',
      },
    },

    template: `
      <a class="btn external_url" :href="externalUrl" target="_blank" rel="noopener noreferrer">
        <i class="fa fa-external-link"></i>
      </a>
    `,
  });
})();
