import SearchBoxDefaultExample from './search_box.default.example.vue';
import SearchBoxByClickExample from './search_box.by_click.example.vue';

export default [
  {
    name: 'Search Box',
    items: [
      {
        id: 'search-box-default',
        name: 'default',
        component: SearchBoxDefaultExample,
      },
      {
        id: 'search-box-by-click',
        name: 'search by click',
        component: SearchBoxByClickExample,
      },
    ],
  },
];
