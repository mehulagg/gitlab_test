import { withKnobs, boolean, select, text } from '@storybook/addon-knobs';
import documentedStoriesOf from '../utils/documented_stories';
import { variantOptions } from '../utils/constants';
import readme from '../../components/base/table/table.md';
import { GlTable } from '../../index';

const components = {
  GlTable,
};

const tableItems = [
  {
    column_one: 'test',
    col_2: 1234,
  },
  {
    column_one: 'test2',
    col_2: 5678,
  },
  {
    column_one: 'test3',
    col_2: 9101,
  },
];

function generateProps() {
  const props = {
    striped: {
      type: Boolean,
      default: boolean('striped', false),
    },
    bordered: {
      type: Boolean,
      default: boolean('bordered', false),
    },
    outlined: {
      type: Boolean,
      default: boolean('outlined', false),
    },
    small: {
      type: Boolean,
      default: boolean('small', false),
    },
    hover: {
      type: Boolean,
      default: boolean('hover', false),
    },
    dark: {
      type: Boolean,
      default: boolean('dark', false),
    },
    fixed: {
      type: Boolean,
      default: boolean('fixed', false),
    },
    footClone: {
      type: Boolean,
      default: boolean('foot-clone', false),
    },
  };

  return props;
}

documentedStoriesOf('base|table', readme)
  .addDecorator(withKnobs)
  .add('default', () => ({
    components,
    props: generateProps(),
    template: `
      <gl-table 
        :items="$options.items"
        :fields="$options.fields"
        :striped="striped"
        :bordered="bordered"
        :outlined="outlined"
        :small="small"
        :hover="hover"
        :dark="dark"
        :fixed="fixed"
        :foot-clone="footClone"
      />
    `,
    fields: [
      {
        key: 'column_one',
        label: 'Column One',
        variant: select('variant', variantOptions, variantOptions.secondary),
        sortable: boolean('sortable', false),
        isRowHeader: boolean('isRowHeader', false),
      },
      {
        key: 'col_2',
        label: 'Column 2',
        formatter: value => `${text('formatterExample', '$')}${value}`,
      },
    ],
    items: tableItems,
  }))
  .add('empty', () => ({
    components,
    template: `
      <gl-table show-empty />
    `,
  }))
  .add('with filter', () => ({
    components,
    template: `<div>
      <gl-form-input v-model="filter" placeholder="Type to search" />
      <br />
      <gl-table :items="$options.items" :fields="$options.fields" :filter=filter />
     </div>`,
    items: tableItems,
    data() {
      return {
        filter: null,
      };
    },
  }));
