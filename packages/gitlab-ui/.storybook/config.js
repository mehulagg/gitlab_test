import { configure } from '@storybook/vue';
import { setOptions } from '@storybook/addon-options';

const req = require.context('../stories', true, /js$/);

function loadStories() {
  req.keys().forEach(filename => req(filename));
  require('../stories/charts/chart');
  require('../stories/charts/area');
}

setOptions({
  name: 'gitlab-ui',
  url: 'https://gitlab.com/gitlab-org/gitlab-ui',
  addonPanelInRight: true,
});

configure(loadStories, module);
