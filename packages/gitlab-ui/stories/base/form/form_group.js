import { withKnobs, text, select, boolean } from '@storybook/addon-knobs';
import documentedStoriesOf from '../../utils/documented_stories';
import { sizeOptions } from '../../utils/constants';
import readme from '../../../components/base/form/form_group/form_group.md';
import { GlFormGroup } from '../../../index';

const components = {
  GlFormGroup,
};

function generateProps({
  id = 'group-1',
  label = 'Label Name',
  description = 'form group description',
  horizontal = false,
} = {}) {
  return {
    id: {
      type: String,
      default: text('id', id),
    },
    label: {
      type: String,
      default: text('label', label),
    },
    labelSize: {
      type: String,
      default: select('label-size', sizeOptions, sizeOptions.sm),
    },
    description: {
      type: String,
      default: text('description', description),
    },
    horizontal: {
      type: Boolean,
      default: boolean('horizontal', horizontal),
    },
  };
}

documentedStoriesOf('base|form/form-group', readme)
  .addDecorator(withKnobs)
  .add('default', () => ({
    props: generateProps(),
    components,
    template: `
      <gl-form-group 
        :id="id"
        :label="label" 
        :label-size="labelSize" 
        :description="description"
        :horizontal="horizontal"
        label-for="label1"
      >
        <gl-form-input id="input1" />
      </gl-form-group>
    `,
  }))
  .add('with validations', () => ({
    props: generateProps({ label: 'Name', description: 'please enter your name' }),
    components,
    computed: {
      state() {
        return this.name.length >= 4;
      },
      validFeedback() {
        return this.state === true ? 'Thank you' : '';
      },
      invalidFeedback() {
        let feedbackText = 'Please enter something';

        if (this.name.length > 4) {
          feedbackText = '';
        } else if (this.name.length > 0) {
          feedbackText = 'Enter at least 4 characters';
        }

        return feedbackText;
      },
    },
    data() {
      return {
        name: '',
      };
    },
    template: `
    <gl-form-group 
      :id="id"
      :label="label" 
      :label-size="labelSize" 
      :description="description"
      :valid-feedback="validFeedback"
      :invalid-feedback="invalidFeedback"
      :state="state"
      label-for="label1"
    >
      <gl-form-input id="input1" :state="state" v-model.trim="name" />
    </gl-form-group>
    `,
  }));
