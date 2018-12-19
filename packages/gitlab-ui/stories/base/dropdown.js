import { withKnobs } from '@storybook/addon-knobs/dist/deprecated';
import documentedStoriesOf from '../utils/documented_stories';
import readme from '../../components/base/dropdown/dropdown.md';
import { GlDropdown, GlDropdownDivider, GlDropdownHeader, GlDropdownItem } from '../../index';

const components = {
  GlDropdown,
  GlDropdownDivider,
  GlDropdownHeader,
  GlDropdownItem,
};

documentedStoriesOf('base|dropdown', readme)
  .addDecorator(withKnobs)
  .add('default', () => ({
    props: {},
    components,
    template: `
      <gl-dropdown text="Some dropdown">
        <gl-dropdown-item>First item</gl-dropdown-item>
        <gl-dropdown-item>Second item</gl-dropdown-item>
        <gl-dropdown-item>Last item</gl-dropdown-item>
      </gl-dropdown>`,
    mounted() {
      this.$nextTick(() => this.$el.querySelector('.dropdown-toggle').click());
    },
  }))
  .add('with links', () => ({
    props: {},
    components,
    template: `
      <gl-dropdown text="Some dropdown">
        <gl-dropdown-item href="https://about.gitlab.com/">First link</gl-dropdown-item>
        <gl-dropdown-item href="https://about.gitlab.com/">Second link</gl-dropdown-item>
        <gl-dropdown-item href="https://about.gitlab.com/">Last link</gl-dropdown-item>
      </gl-dropdown>`,
    mounted() {
      this.$nextTick(() => this.$el.querySelector('.dropdown-toggle').click());
    },
  }))
  .add('with divider', () => ({
    props: {},
    components,
    template: `
      <gl-dropdown text="Some dropdown">
        <gl-dropdown-item>Above divider</gl-dropdown-item>
        <gl-dropdown-divider />
        <gl-dropdown-item>Below divider</gl-dropdown-item>
      </gl-dropdown>`,
    mounted() {
      this.$nextTick(() => this.$el.querySelector('.dropdown-toggle').click());
    },
  }))
  .add('with header', () => ({
    props: {},
    components,
    template: `
      <gl-dropdown text="Some dropdown">
        <gl-dropdown-header>First group</gl-dropdown-header>
        <gl-dropdown-item>First item</gl-dropdown-item>
        <gl-dropdown-item>Second item</gl-dropdown-item>
        <gl-dropdown-divider />
        <gl-dropdown-header>Second group</gl-dropdown-header>
        <gl-dropdown-item>Last item</gl-dropdown-item>
      </gl-dropdown>`,
    mounted() {
      this.$nextTick(() => this.$el.querySelector('.dropdown-toggle').click());
    },
  }));
