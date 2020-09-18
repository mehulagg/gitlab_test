import Vue from 'vue';
import Translate from '~/vue_shared/translate';
import createStore from './store';
import GlobalSearchApp from './components/app.vue';

Vue.use(Translate);

export default () => {
  const el = document.getElementById('js-global-search');
  const { searchEmptySvgPath } = el.dataset;

  if (!el) return false;

  return new Vue({
    el,
    store: createStore(),
    components: {
      GlobalSearchApp,
    },

    render(createElement) {
      return createElement('global-search-app', {
        props: {
          searchEmptySvgPath,
        },
      });
    },
  });
};
