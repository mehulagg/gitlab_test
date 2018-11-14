import { configure } from '@storybook/vue';
import { setOptions } from '@storybook/addon-options';

import Vue from 'vue';

function loadStories() {
  // You can require as many stories as you need.
  require('../stories/base/pagination.js');
  require('../stories/base/progress_bar');
  require('../stories/base/modal');
  require('../stories/base/loading_icon');
  require('../stories/base/skeleton_loading');
  require('../stories/base/tooltip');
  require('../stories/base/link');
  require('../stories/base/button');
}

setOptions({
  name: 'gitlab-ui',
  url: 'https://gitlab.com/gitlab-org/gitlab-ui',
  addonPanelInRight: true,
});

configure(loadStories, module);
