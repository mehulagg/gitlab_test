import { withKnobs, select, boolean, text } from '@storybook/addon-knobs/vue';
import documentedStoriesOf from '../utils/documented_stories';
import {
  sizeOptionsWithNoDefault,
  buttonVariantOptions,
  targetOptions,
} from '../utils/constants';
import readme from '../../components/base/button/button.md';
import { GlButton } from '../../index';

const components = {
  GlButton,
};

function generateProps({
  variant = buttonVariantOptions.primary,
  size = sizeOptionsWithNoDefault.default,
  withLink = false,
} = {}) {
  let props = {
    variant: {
      type: String,
      default: select('variant', buttonVariantOptions, variant),
    },
    size: {
      type: String,
      default: select('size', sizeOptionsWithNoDefault, size),
    },
    disabled: {
      type: Boolean,
      default: boolean('disabled', false),
    },
  };

  if (withLink) {
    props = {
      ...props,
      href: {
        type: String,
        default: text('href', '#'),
      },
      target: {
        type: String,
        default: select('target', targetOptions, targetOptions.null),
      },
    };
  }

  return props;
}

documentedStoriesOf('button', readme)
  .addDecorator(withKnobs)
  .add('default', () => ({
    props: generateProps(),
    components,
    template: `
      <gl-button
        :variant="variant"
        :size="size"
        :disabled="disabled"
      >
        This is a button
      </gl-button>
    `,
  }))
  .add('link button', () => ({
    props: generateProps({ withLink: true }),
    components,
    template: `
      <gl-button
        :variant="variant"
        :size="size"
        :disabled="disabled"
        :href="href"
        :target="target"
      >
        This is a link button
      </gl-button>
    `,
  }));
