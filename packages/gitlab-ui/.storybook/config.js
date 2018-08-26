import { configure } from '@storybook/vue';
import { setOptions } from '@storybook/addon-options';

import Vue from 'vue';

// Import your custom components.
import progressBar from '../components/base/progress_bar.vue';

// Register custom components.
Vue.component('gl-progress-bar', progressBar);

function loadStories() {
  // You can require as many stories as you need.
  require('../stories/base/progress_bar');
}

setOptions({
  name: 'gitlab-ui',
  addonPanelInRight: true,
});

configure(loadStories, module);
