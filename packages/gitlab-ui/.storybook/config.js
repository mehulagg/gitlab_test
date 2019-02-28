import { configure } from '@storybook/vue';
import { withOptions } from '@storybook/addon-options';

const req = require.context('../stories', true, /js$/);

function loadStories() {
  req.keys().forEach(filename => req(filename));
}

withOptions({
  name: 'gitlab-ui',
  url: 'https://gitlab.com/gitlab-org/gitlab-ui',
  addonPanelInRight: true,
  hierarchyRootSeparator: /\|/,
});

configure(loadStories, module);
