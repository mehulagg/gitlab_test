import { withKnobs, text, select } from '@storybook/addon-knobs/vue';
import documentedStoriesOf from '../utils/documented_stories';
import { targetOptions } from '../utils/constants';
import readme from '../../documentation/link.md';
import { GlLink } from '../../index';

const components = {
  GlLink,
};

function generateProps({ href = '#' } = {}) {
  return {
    href: {
      type: String,
      default: text('href', href)
    },
    target: {
      type: String,
      default: select('target', targetOptions, targetOptions.null),
    },
  };
}

documentedStoriesOf('link', readme)
  .addDecorator(withKnobs)
  .add('default link', () => ({
    props: generateProps(),
    components,
    template: `
      <gl-link
        :href="href"
        :target="target"
      >
          This is a link
      </gl-link>`
  }));
