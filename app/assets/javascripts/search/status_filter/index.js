import Vue from 'vue';
import Translate from '~/vue_shared/translate';
import StatusFilter from './components/app.vue';

Vue.use(Translate);

export default () => {
  const el = document.getElementById('js-search-filter-by-status');

  return new Vue({
    el,
    components: {
      StatusFilter,
    },

    render(createElement) {
      return createElement('status-filter');
    },
  });
};
