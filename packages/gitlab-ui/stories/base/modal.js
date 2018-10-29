import Vue from 'vue';
import { storiesOf } from '@storybook/vue';
import { withKnobs, text, boolean, number, select } from '@storybook/addon-knobs/vue';
import { variantOptionsWithNoDefault } from '../utils/constants';
import { GlModal, GlModalDirective } from '../../index';

const components = {
  GlModal,
};

const directives = {
  GlModalDirective,
};

function generateTemplate({ visible = false } = {}) {
  return `
    <div>
      <button
        type="button"
        v-gl-modal-directive="'test-modal-id'"
      >
        Open modal
      </button>
      <gl-modal
        :header-bg-variant="headerBgVariant"
        :header-border-variant="headerBorderVariant"
        :header-text-variant="headerTextVariant"
        :body-bg-variant="bodyBgVariant"
        :body-text-variant="bodyTextVariant"
        :footer-bg-variant="footerBgVariant"
        :footer-border-variant="footerBorderVariant"
        :footer-text-variant="footerTextVariant"
        :visible="${visible}"
        modal-id="test-modal-id"
        title="Example title"
        no-fade
      >
        This is my content
      </gl-modal>
    </div>
  `;
}

function generateProps({
  variant = variantOptionsWithNoDefault.default
} = {}) {
  return {
    headerBgVariant: {
      type: String,
      default: select('header bg', variantOptionsWithNoDefault, variant),
    },
    headerBorderVariant: {
      type: String,
      default: select('header border', variantOptionsWithNoDefault, variant),
    },
    headerTextVariant: {
      type: String,
      default: select('header text', variantOptionsWithNoDefault, variant),
    },
    bodyBgVariant: {
      type: String,
      default: select('body bg', variantOptionsWithNoDefault, variant),
    },
    bodyTextVariant: {
      type: String,
      default: select('body text', variantOptionsWithNoDefault, variant),
    },
    footerBgVariant: {
      type: String,
      default: select('footer bg', variantOptionsWithNoDefault, variant),
    },
    footerBorderVariant: {
      type: String,
      default: select('footer border', variantOptionsWithNoDefault, variant),
    },
    footerTextVariant: {
      type: String,
      default: select('footer text', variantOptionsWithNoDefault, variant),
    },
  }
}

storiesOf('modal', module)
  .addDecorator(withKnobs)
  .add('default', () => ({
    props: generateProps(),
    components,
    directives,
    template: generateTemplate(),
  }))
  .add('opened modal', () => ({
    props: generateProps(),
    components,
    directives,
    template: generateTemplate({ visible: true }),
  }));
