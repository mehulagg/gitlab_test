export default () => ({
  endpoint: '',

  isLoading: false,
  error: null,

  designs: [],
  currentFilterIndex: 0,
  filterOptions: ['all', 'synced', 'pending', 'failed', 'never']
});