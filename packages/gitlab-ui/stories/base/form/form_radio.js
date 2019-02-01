import { withKnobs, select, boolean, text } from '@storybook/addon-knobs';
import documentedStoriesOf from '../../utils/documented_stories';
import { sizeOptions, variantOptions } from '../../utils/constants';
import readme from '../../../components/base/form/form_radio/form_radio.md';
import { GlFormRadio, GlFormRadioGroup } from '../../../index';

const components = {
  GlFormRadio,
  GlFormRadioGroup,
};

function generateProps({ stacked = false, buttons = false, groupName = 'radio-group-name' } = {}) {
  return {
    size: {
      type: String,
      default: select('size', sizeOptions, sizeOptions.sm),
    },
    stacked: {
      type: Boolean,
      default: boolean('stacked', stacked),
    },
    buttons: {
      type: Boolean,
      default: boolean('buttons', buttons),
    },
    buttonVariant: {
      type: String,
      default: select('button-variant', variantOptions, variantOptions.secondary),
    },
    name: {
      type: String,
      default: text('name', groupName),
    },
  };
}

documentedStoriesOf('base|form/form-radio', readme)
  .addDecorator(withKnobs)
  .add('Radios using code', () => ({
    components,
    props: generateProps(),
    data() {
      return {
        selected: 'Pizza',
        options: [
          { value: 'Pizza', text: 'Pizza' },
          { value: 'Tacos', text: 'Tacos' },
          { value: 'Burger', text: 'Burguer', disabled: boolean('disabled', false) },
        ],
      };
    },
    template: `
      <gl-form-radio-group 
        id="food-radios"
        v-model="selected"
        :options="options"
        :size="size"
        :stacked="stacked"
        :buttons="buttons"
        :button-variant="buttonVariant"
        :name="name"
        :checked="selected"
      >
      </gl-form-radio-group>
    `,
  }));
