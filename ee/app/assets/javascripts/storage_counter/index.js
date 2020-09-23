import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';
import App from './components/app.vue';
import GroupsService from './services/groups_service';

Vue.use(VueApollo);

export default () => {
  const el = document.getElementById('js-storage-counter-app');
  const {
    namespacePath,
    helpPagePath,
    purchaseStorageUrl,
    dashboardGroupsEndpoint,
    isTemporaryStorageIncreaseVisible,
  } = el.dataset;

  const apolloProvider = new VueApollo({
    defaultClient: createDefaultClient(),
  });

  const groupsService = new GroupsService(dashboardGroupsEndpoint);

  return new Vue({
    el,
    apolloProvider,
    render(h) {
      return h(App, {
        props: {
          groupsService,
          namespacePath,
          helpPagePath,
          purchaseStorageUrl,
          isTemporaryStorageIncreaseVisible,
        },
      });
    },
  });
};
