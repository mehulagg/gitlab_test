import Vue from 'vue';
import issuableApp from './components/app.vue';
import IssuableHeaderWarnings from './components/issuable_header_warnings.vue';
import { parseIssuableData } from './utils/parse_data';
import { store } from '~/notes/stores';

export default function initIssueableApp() {
  // eslint-disable-next-line no-new
  new Vue({
    el: document.getElementById('js-issuable-header-warnings'),
    store,
    render(createElement) {
      return createElement(IssuableHeaderWarnings);
    },
  });

  return new Vue({
    el: document.getElementById('js-issuable-app'),
    components: {
      issuableApp,
    },
    render(createElement) {
      return createElement('issuable-app', {
        props: parseIssuableData(),
      });
    },
  });
}
