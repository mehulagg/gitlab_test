import DropdownDefaultExample from './dropdown.default.example.vue';
import DropdownLinksExample from './dropdown.links.example.vue';
import DropdownWithDividerExample from './dropdown.with_divider.example.vue';
import DropdownWithHeaderExample from './dropdown.with_header.example.vue';
import DropdownWithSearchExample from './dropdown.with_search.example.vue';
import DropdownNoCaretExample from './dropdown.no_caret.example.vue';
import DropdownSplitExample from './dropdown.split.example.vue';

export default [
  {
    name: 'Dropdown',
    items: [
      {
        id: 'dropdown-default',
        name: 'Default',
        description: 'Default Dropdown',
        component: DropdownDefaultExample,
      },
      {
        id: 'dropdown-links',
        name: 'With Links',
        description: 'Dropdown with links as items',
        component: DropdownLinksExample,
      },
      {
        id: 'dropdown-with-divider',
        name: 'With Divider',
        description: 'Dropdown with divider',
        component: DropdownWithDividerExample,
      },
      {
        id: 'dropdown-with-header',
        name: 'With Header',
        description: 'Dropdown with section header',
        component: DropdownWithHeaderExample,
      },
      {
        id: 'dropdown-with-search',
        name: 'With Search',
        description: 'Dropdown with search field',
        component: DropdownWithSearchExample,
      },
      {
        id: 'dropdown-no-caret',
        name: 'No Caret',
        description: 'Dropdown with no caret',
        component: DropdownNoCaretExample,
      },
      {
        id: 'dropdown-split',
        name: 'Split',
        description: 'Split Dropdown',
        component: DropdownSplitExample,
      },
    ],
  },
];
