export default () => ({
  inputValue: '',
  isLoadingProjects: false,
  projectEndpoints: {
    list: null,
    add: null,
  },
  searchQuery: '',
  totalPages: 0,
  currentPage: 0,
  totalResults: 0,
  projects: [],
  projectSearchResults: [],
  selectedProjects: [],
  messages: {
    noResults: false,
    searchError: false,
    minimumQuery: false,
  },
  searchCount: 0,
});
