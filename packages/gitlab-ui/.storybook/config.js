import { configure } from '@storybook/vue';
import { setOptions } from '@storybook/addon-options';

import Vue from "vue";

// Import your custom components.
import Pagination from '../components/base/pagination.vue';
import progressBar from '../components/base/progress_bar.vue';
import modal from '../components/base/modal.vue';
import link from '../components/base/link.vue';
import loadingIcon from '../components/base/loading_icon.vue';
import skeletonLoading from '../components/base/skeleton_loading.vue';

// Import your custom directives.
import vModal from '../directives/modal';
import vTooltip from '../directives/tooltip';

// Register custom components.
Vue.component('gl-pagination', Pagination);
Vue.component('gl-progress-bar', progressBar);
Vue.component('gl-modal', modal);
Vue.component('gl-link', link);
Vue.component('gl-loading-icon', loadingIcon);
Vue.component('gl-skeleton-loading', skeletonLoading);

// Register custom directives.
Vue.directive('gl-modal', vModal);
Vue.directive('gl-tooltip', vTooltip);

function loadStories() {
  // You can require as many stories as you need.
  require('../stories/base/pagination.js');
  require('../stories/base/progress_bar');
  require('../stories/base/modal');
  require('../stories/base/loading_icon');
  require('../stories/base/skeleton_loading');
  require('../stories/tooltip');
  require('../stories/base/link');
}

setOptions({
  name: 'gitlab-ui',
  addonPanelInRight: true,
});

configure(loadStories, module);
