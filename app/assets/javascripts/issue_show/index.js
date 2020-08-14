import Vue from 'vue';
import issuableApp from './components/app.vue';
import { parseIssuableData } from './utils/parse_data';
import { store } from '~/notes/stores';
import { createDesignManagement } from '~/design_management';
import IssuableHeaderWarnings from '~/vue_shared/components/issuable/issuable_header_warnings.vue';

export default function initIssueableApp() {
  const issuableData = parseIssuableData();
  const designManagmentData = issuableData.design_management_enabled ? createDesignManagement(issuableData) : {};

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
    ...designManagmentData,
    components: {
      issuableApp,
    },
    render(createElement) {
      return createElement('issuable-app', {
        props: issuableData,
      });
    },
  });
}
