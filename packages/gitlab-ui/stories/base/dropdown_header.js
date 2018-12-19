import { withKnobs } from '@storybook/addon-knobs/dist/deprecated';
import documentedStoriesOf from '../utils/documented_stories';
import readme from '../../components/base/dropdown/dropdown_header.md';
import { GlDropdownHeader } from '../../index';

const components = {
  GlDropdownHeader,
};

documentedStoriesOf('base|dropdown/dropdown-header', readme)
  .addDecorator(withKnobs)
  .add('default', () => ({
    props: {},
    components,
    template: '<gl-dropdown-header>Some header</gl-dropdown-header>',
  }));
