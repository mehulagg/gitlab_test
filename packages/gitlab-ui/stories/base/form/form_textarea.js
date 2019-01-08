import documentedStoriesOf from '../../utils/documented_stories';
import readme from '../../../components/base/form/form_textarea/form_textarea.md';
import { GlFormTextarea } from '../../../index';

const components = {
  GlFormTextarea,
};

const template = `
  <gl-form-textarea
    v-model="model"
    :placeholder="placeholder"
    :rows="5"
  />
`;

function generateProps() {
  return {
    model: {
      type: String,
      default:
        'We take inspiration from other companies, and we always go for the boring solutions. Just like the rest of our work, we continually adjust our values and strive always to make them better. We used to have more values, but it was difficult to remember them all, so we condensed them and gave sub-values and created an acronym. Everyone is welcome to suggest improvements.',
    },
    placeholder: {
      type: String,
      default: 'hello',
    },
  };
}

documentedStoriesOf('base|form/form-textarea', readme).add('default', () => ({
  components,
  props: generateProps(),
  template,
}));
