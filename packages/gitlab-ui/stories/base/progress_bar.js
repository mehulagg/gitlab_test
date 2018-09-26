import Vue from 'vue';
import { withKnobs, text, boolean, number, select } from '@storybook/addon-knobs/vue';
import documentedStoriesOf from '../utils/documented_stories';
import { variantOptions } from '../utils/constants';
import readme from '../../documentation/progress_bar.md';
import { ProgressBar } from '../../index';

const components = {
  'gl-progress-bar': ProgressBar,
};

const template = '<gl-progress-bar :value="value" :variant="variant" />';

function generateProps({
  value = 30,
  variant = variantOptions.primary
} = {}) {
  return {
    value: {
      type: Number,
      default: number('value', value),
    },
    variant: {
      type: String,
      default: select('variant', variantOptions, variant),
    }
  };
}

documentedStoriesOf('progress-bar', readme)
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
