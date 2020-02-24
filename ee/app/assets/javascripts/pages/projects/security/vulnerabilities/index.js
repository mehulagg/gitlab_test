import Vue from 'vue';
import VulnerabilitiesApp from 'ee/vulnerabilities/components/vulnerabilities_app.vue';
import createStore from 'ee/security_dashboard/store';

// TODO: Not hard-code these

const el = document.getElementById('app');
const { dashboardDocumentation, emptyStateSvgPath, vulnerabilitiesEndpoint } = el.dataset;
const props = {
  emptyStateSvgPath,
  dashboardDocumentation,
  vulnerabilitiesEndpoint,
};

function render() {
  if (!el) {
    return false;
  }

  return new Vue({
    el,
    store: createStore(),
    components: {
      VulnerabilitiesApp,
    },
    render(createElement) {
      return createElement('vulnerabilities-app', {
        props,
      });
    },
  });
}

window.addEventListener('DOMContentLoaded', () => {
  render();
});
