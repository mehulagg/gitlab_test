import { withKnobs } from '@storybook/addon-knobs/dist/deprecated';
import documentedStoriesOf from '../utils/documented_stories';
import readme from '../../components/base/dropdown/dropdown_divider.md';
import { GlDropdownDivider } from '../../index';

const components = {
  GlDropdownDivider,
};

documentedStoriesOf('base|dropdown/dropdown-divider', readme)
  .addDecorator(withKnobs)
  .add('default', () => ({
    props: {},
    components,
    template: '<gl-dropdown-divider />',
  }));
