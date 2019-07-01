import FilteredSearchTokenKeys from './filtered_search_token_keys';

const tokenKeys = [
  {
    key: 'status',
    type: 'string',
    param: 'status',
    symbol: '',
    icon: 'messages',
    tag: 'status',
  },
  {
    key: 'author',
    type: 'string',
    param: 'username',
    symbol: '@',
    icon: 'pencil',
    tag: '@author',
  },
  {
    key: 'assignee',
    type: 'string',
    param: 'username',
    symbol: '@',
    icon: 'user',
    tag: '@assignee',
  },
  {
    key: 'milestone',
    type: 'string',
    param: 'title',
    symbol: '%',
    icon: 'clock',
    tag: '%milestone',
  },
  {
    key: 'label',
    type: 'array',
    param: 'name[]',
    symbol: '~',
    icon: 'labels',
    tag: '~label',
  },
];

const ProductivityAnalyticsFilteredSearchTokenKeys = new FilteredSearchTokenKeys(tokenKeys);

export default ProductivityAnalyticsFilteredSearchTokenKeys;
