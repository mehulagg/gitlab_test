import { configure } from '@storybook/vue';
import { setOptions } from '@storybook/addon-options';

const req = require.context('../stories/base', true, /js$/);

function loadStories() {
  req.keys().forEach(filename => req(filename));
}

setOptions({
  name: 'gitlab-ui',
  url: 'https://gitlab.com/gitlab-org/gitlab-ui',
  addonPanelInRight: true,
});

configure(loadStories, module);
