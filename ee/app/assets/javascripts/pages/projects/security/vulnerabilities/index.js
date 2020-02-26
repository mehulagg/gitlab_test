import Vue from 'vue';
import VulnerabilitiesApp from 'ee/vulnerabilities/components/vulnerabilities_app.vue';
import createDefaultClient from '~/lib/graphql';
import VueApollo from 'vue-apollo';

Vue.use(VueApollo);

const el = document.getElementById('app');
const { dashboardDocumentation, emptyStateSvgPath, vulnerabilitiesEndpoint } = el.dataset;
const props = {
  emptyStateSvgPath,
  dashboardDocumentation,
  vulnerabilitiesEndpoint,
};
const apolloProvider = new VueApollo({
  defaultClient: createDefaultClient(),
});

function render() {
  if (!el) {
    return false;
  }

  return new Vue({
    el,
    apolloProvider,
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
