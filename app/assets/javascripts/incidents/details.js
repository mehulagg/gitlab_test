import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';
import Incident from './components/incident_details.vue';

Vue.use(VueApollo);
export default () => {
  const selector = '#js-incident_details';

  const domEl = document.querySelector(selector);
  const { projectPath, incidentId } = domEl.dataset;

  const apolloProvider = new VueApollo({
    defaultClient: createDefaultClient(),
  });

  return new Vue({
    el: selector,
    provide: {
      projectPath,
      incidentId,
    },
    apolloProvider,
    components: {
      Incident,
    },
    render(createElement) {
      return createElement('incident-details');
    },
  });
};
