import { configure } from '@storybook/vue';

import Vue from 'vue';

// Import your custom components.
import progressBar from '../components/progressBar.vue';

// Register custom components.
Vue.component('gl-progress-bar', progressBar);

function loadStories() {
  // You can require as many stories as you need.
  require('../stories');
}

configure(loadStories, module);
