import Vue from 'vue';
import Translate from '~/vue_shared/translate';
import RegistryExplorer from './pages/index.vue';
import { createStore } from './stores';
import createRouter from './router';

Vue.use(Translate);

export default () => {
  const el = document.getElementById('js-container-registry');
  if (!el) {
    return null;
  }
  const { projectPath, endpoint } = el.dataset;
  const base = projectPath ? `${projectPath}/container_registry` : endpoint.replace('.json', '');
  const store = createStore();
  const router = createRouter(base, store);
  store.dispatch('setInitialState', el.dataset);

  return new Vue({
    el,
    store,
    router,
    components: {
      RegistryExplorer,
    },
    render(createElement) {
      return createElement('registry-explorer');
    },
  });
};
