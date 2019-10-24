export default () => ({
  endpoint: '',

  isLoading: false,
  error: null,

  designs: [],

  searchFilter: '',
  currentFilterIndex: 0,
  filterOptions: ['all', 'synced', 'pending', 'failed', 'never']
});