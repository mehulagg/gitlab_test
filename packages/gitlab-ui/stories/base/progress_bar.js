import Vue from 'vue';
import { storiesOf } from '@storybook/vue';
import { withKnobs, text, boolean, number, select } from '@storybook/addon-knobs/vue';
import { variantOptions } from '../utils/constants';

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

storiesOf('progress-bar', module)
  .addDecorator(withKnobs)
  .add('default', () => ({
    props: generateProps(),
    template,
  }))
  .add('success variant', () => ({
    props: generateProps({
      variant: variantOptions.success,
    }),
    template,
  }));
