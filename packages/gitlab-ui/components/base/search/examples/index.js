import SearchBoxExample from './search_box.default.example.vue';
import SearchBoxLoadingExample from './search_box.loading.example.vue';
import SearchBoxDisabledExample from './search_box.disabled.example.vue';
import SearchBoxFilledExample from './search_box.filled.example.vue';
import SearchBoxPlaceholderExample from './search_box.placeholder.example.vue';

export default [
  {
    name: 'Search Box',
    items: [
      {
        id: 'search-box-default',
        name: 'default state',
        component: SearchBoxExample,
      },
      {
        id: 'search-box-disabled',
        name: 'disabled state',
        component: SearchBoxDisabledExample,
      },
      {
        id: 'search-box-loading',
        name: 'loading state',
        component: SearchBoxLoadingExample,
      },
      {
        id: 'search-box-filled',
        name: 'with content',
        component: SearchBoxFilledExample,
      },
      {
        id: 'search-box-placeholder',
        name: 'with custom placeholder',
        component: SearchBoxPlaceholderExample,
      },
    ],
  },
];
