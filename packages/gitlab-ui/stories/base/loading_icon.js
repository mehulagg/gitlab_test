import { withKnobs, text, boolean, number } from '@storybook/addon-knobs/vue';
import documentedStoriesOf from '../utils/documented_stories';
import readme from '../../components/base/loading_icon/loading_icon.md';
import { GlLoadingIcon } from '../../index';

const components = {
  GlLoadingIcon,
};

const template = `
  <gl-loading-icon
    :label="label"
    :size="size"
    :inline="inline"
  />
`;

function generateProps({ inline } = {}) {
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
    components,
    template,
  }))
  .add('inline', () => ({
    props: generateProps({
      inline: true,
    }),
    components,
    template,
  }));
