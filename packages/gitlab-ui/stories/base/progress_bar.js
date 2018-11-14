import { withKnobs, number, select } from '@storybook/addon-knobs/vue';
import documentedStoriesOf from '../utils/documented_stories';
import { variantOptions } from '../utils/constants';
import { GlProgressBar } from '../../index';

const components = {
  GlProgressBar,
};

const template = '<gl-progress-bar :value="value" :variant="variant" />';

function generateProps({ value = 30, variant = variantOptions.primary } = {}) {
  return {
    value: {
      type: Number,
      default: number('value', value),
    },
    variant: {
      type: String,
      default: select('variant', variantOptions, variant),
    },
  };
}

documentedStoriesOf('progress-bar', '')
  .addDecorator(withKnobs)
  .add('default', () => ({
    props: generateProps(),
    components,
    template,
  }))
  .add('success variant', () => ({
    props: generateProps({
      variant: variantOptions.success,
    }),
    components,
    template,
  }));
