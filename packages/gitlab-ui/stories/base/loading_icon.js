import Vue from 'vue';
import { storiesOf } from '@storybook/vue';
import { withKnobs, text, boolean, select } from '@storybook/addon-knobs/vue';
import { variantOptions } from '../utils/constants';

const template = `
  <gl-loading-icon
    :label="label"
    :size="size"
    :inline="inline"
  />
`;

function generateProps({
  inline,
} = {}) {
  return {
    label: {
      type: String,
      default: text('aria label'),
    },
    size: {
      type: Number,
      default: select('size', [1,2,3,4,5], 1),
    },
    inline: {
      type: Boolean,
      default: boolean('inline', inline),
    },
  };
}

storiesOf('loading-icon', module)
  .addDecorator(withKnobs)
  .add('default', () => ({
    props: generateProps(),
    template,
  }))
  .add('inline', () => ({
    props: generateProps({
      inline: true,
    }),
    template,
  }));
