import { withKnobs } from '@storybook/addon-knobs/vue';
import documentedStoriesOf from '../utils/documented_stories';
import readme from '../../components/base/search/search_box.md';
import { GlSearchBox } from '../../index';

const components = {
  GlSearchBox,
};

documentedStoriesOf('base|search-box', readme)
  .addDecorator(withKnobs)
  .add('default', () => ({
    components,
    template: `
      <gl-search-box />
    `,
  }));
