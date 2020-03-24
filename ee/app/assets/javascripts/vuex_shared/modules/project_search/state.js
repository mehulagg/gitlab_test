export default () => ({
  searchQuery: '',
  projectSearchResults: [],
  messages: {
    noResults: false,
    searchError: false,
    minimumQuery: false,
  },
  searchCount: 0,
  pageInfo: {
    page: 0,
    nextPage: 0,
    total: 0,
    totalPages: 0,
  },
});
