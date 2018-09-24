import Vue from 'vue';
import { withKnobs, text, boolean, number } from '@storybook/addon-knobs/vue';
import documentedStoriesOf from '../utils/documented_stories';
import { variantOptions } from '../utils/constants';
import readme from '../../documentation/loading_icon.md';

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
      default: number('size', 1, {
        range: true,
        min: 1,
        max: 5,
        step: 1,
      }),
    },
    inline: {
      type: Boolean,
      default: boolean('inline', inline),
    },
  };
}

documentedStoriesOf('loading-icon', readme)
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
