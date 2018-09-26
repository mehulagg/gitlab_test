import { configure } from '@storybook/vue';
import { setOptions } from '@storybook/addon-options';

import Vue from "vue";

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
