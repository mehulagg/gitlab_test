import Vue from 'vue';
import GlFeatureFlagsPlugin from '~/vue_shared/gl_feature_flags_plugin';

if (process.env.NODE_ENV !== 'production') {
  Vue.config.productionTip = false;
}

import IssuableApp from '~/issue_show/components/app.vue';
import RelatedMergeRequests from '~/related_merge_requests/components/related_merge_requests.vue';
Vue.component('issuable-app', IssuableApp);
Vue.component('related-merge-requests', RelatedMergeRequests);

const app = new Vue({
  el: '[data-vue-shell]'
});

Vue.use(GlFeatureFlagsPlugin);
