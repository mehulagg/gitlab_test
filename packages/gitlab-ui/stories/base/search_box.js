import { withKnobs, boolean, text } from '@storybook/addon-knobs';
import documentedStoriesOf from '../utils/documented_stories';
import readme from '../../components/base/search/search_box.md';
import { GlSearchBox } from '../../index';

const components = {
  GlSearchBox,
};

function generateProps({
  searchOnInput = true,
  disabled = false,
  value = '',
  placeholder = 'Search',
  isLoading = false,
} = {}) {
  let props = {
    disabled: {
      type: Boolean,
      default: boolean('disabled', disabled),
    },
    value: {
      type: String,
      default: text('value', value),
    },
    placeholder: {
      type: String,
      default: text('placeholder', placeholder),
    },
  };

  if (searchOnInput) {
    props = {
      ...props,
      isLoading: {
        type: Boolean,
        default: boolean('isLoading', isLoading),
      },
    };
  }

  return props;
}

documentedStoriesOf('base|search-box', readme)
  .addDecorator(withKnobs)
  .add('default', () => ({
    props: generateProps(),
    components,
    template: `
      <gl-search-box
        :value="value" 
        :disabled="disabled"
        :is-loading="isLoading"
        :placeholder="placeholder"
      />
    `,
  }))
  .add('search by click', () => ({
    props: generateProps({ searchOnInput: false }),
    components,
    template: `
      <gl-search-box
        :value="value"
        :search-on-input="false"
        :disabled="disabled"
        :placeholder="placeholder"
      />
    `,
  }));
