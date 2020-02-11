import Vue from 'vue';
import VueApollo from 'vue-apollo';
import Translate from '~/vue_shared/translate';
import createDefaultClient from '~/lib/graphql';
import GeoBlobsApp from './components/app.vue';

Vue.use(Translate);
Vue.use(VueApollo);

export default () => {
  const el = document.getElementById('js-geo-blobs');

  const apolloProvider = new VueApollo({
    defaultClient: createDefaultClient(),
  });

  return new Vue({
    el,
    apolloProvider,
    components: {
      GeoBlobsApp,
    },
    render(createElement) {
      return createElement('geo-blobs-app');
    },
  });
};
