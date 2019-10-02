import Vue from 'vue';
import Vuex from 'vuex';
import router from './router';
import mediator from './plugins/mediator';
import syncWithRouter from './plugins/sync_with_router';
import filters from './modules/filters/index';
import projects from './modules/projects/index';
import projectSelector from './modules/projectSelector/index';
import vulnerabilities from './modules/vulnerabilities/index';

Vue.use(Vuex);

export default ({ plugins = [] } = {}) => {
  const store = new Vuex.Store({
    modules: {
      filters,
      projects,
      projectSelector,
      vulnerabilities,
    },
    plugins: [mediator, syncWithRouter(router), ...plugins],
  });

  store.$router = router;

  return store;
};
