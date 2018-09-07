import { configure } from '@storybook/vue';
import { setOptions } from '@storybook/addon-options';

import Vue from 'vue';

// Import your custom components.
import progressBar from '../components/base/progress_bar.vue';
import modal from '../components/base/modal.vue';

// Import your custom directives.
import vModal from '../directives/modal';

// Register custom components.
Vue.component('gl-progress-bar', progressBar);
Vue.component('gl-modal', modal);

// Register custom directives.
Vue.directive('gl-modal', vModal);

function loadStories() {
  // You can require as many stories as you need.
  require('../stories/base/progress_bar');
  require('../stories/base/modal');
}

setOptions({
  name: 'gitlab-ui',
  addonPanelInRight: true,
});

configure(loadStories, module);
