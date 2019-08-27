import Vue from 'vue';
import Vuex from 'vuex';
import Translate from '~/vue_shared/translate';

import createRouter from './router';
import Elasticsearch from './components/index.vue';

import createStore from './store';

Vue.use(Translate);
Vue.use(Vuex);

const store = createStore();

export default () => {
  const el = document.getElementById('js-elasticsearch');
  const router = createRouter();

  if (!el) {
    return false;
  }

  return new Vue({
    el,
    store,
    router,
    render(createElement) {
      return createElement(Elasticsearch);
    },
  });
};
