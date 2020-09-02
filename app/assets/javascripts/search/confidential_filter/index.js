import Vue from 'vue';
import Translate from '~/vue_shared/translate';
import ConfidentialFilter from './components/confidential_filter.vue';

Vue.use(Translate);

export default () => {
  const el = document.getElementById('js-search-filter-by-confidential');

  if (!el) return false;

  return new Vue({
    el,
    components: {
      ConfidentialFilter,
    },
    data() {
      const { dataset } = this.$options.el;
      return {
        scope: dataset.scope,
        confidential: dataset.confidential,
      };
    },

    render(createElement) {
      return createElement('confidential-filter', {
        props: {
          scope: this.scope,
          confidential: this.confidential,
        },
      });
    },
  });
};
