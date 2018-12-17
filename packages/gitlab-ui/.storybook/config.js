import { configure } from '@storybook/vue';
import { setOptions } from '@storybook/addon-options';

const req = require.context('../stories', true, /js$/);

function loadStories() {
  req.keys().forEach(filename => req(filename));
}

setOptions({
  name: 'gitlab-ui',
  url: 'https://gitlab.com/gitlab-org/gitlab-ui',
  addonPanelInRight: true,
  hierarchyRootSeparator: /\|/,
});

configure(loadStories, module);
