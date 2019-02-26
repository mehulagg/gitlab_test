import { withKnobs } from '@storybook/addon-knobs/vue';
import documentedStoriesOf from '../../utils/documented_stories';
import { GlTabs, GlTab } from '../../../index';

const template = `
  <div>
    <gl-tabs>
      <gl-tab title="First">
        first tab content
      </gl-tab>
      <gl-tab title="Second">
        second tab content
      </gl-tab>
    </gl-tabs>
  </div>
`;

documentedStoriesOf('base|tabs/tabs', '')
  .addDecorator(withKnobs)
  .add('default', () => ({
    components: {
      GlTabs,
      GlTab,
    },
    template,
  }));
