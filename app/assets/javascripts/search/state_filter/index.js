import Vue from 'vue';
import Translate from '~/vue_shared/translate';
import StateFilter from '../components/dropdown_filter.vue';
import { FILTER_HEADER, FILTER_STATES_BY_SCOPE, FILTER_STATES, SCOPES } from './constants';

Vue.use(Translate);

export default () => {
  const el = document.getElementById('js-search-filter-by-state');

  if (!el) return false;

  return new Vue({
    el,
    components: {
      StateFilter,
    },
    data() {
      const { dataset } = this.$options.el;

      return {
        scope: dataset.scope,
        filter: dataset.filter,
      };
    },
    render(createElement) {
      return createElement('state-filter', {
        props: {
          initialFilter: this.filter,
          filtersArray: FILTER_STATES_BY_SCOPE[this.scope],
          filters: FILTER_STATES,
          header: FILTER_HEADER,
          param: 'state',
          scope: this.scope,
          supportedScopes: Object.values(SCOPES),
        },
      });
    },
  });
};
