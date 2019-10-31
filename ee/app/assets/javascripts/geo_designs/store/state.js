import { FILTER_STATES } from './constants';

export default () => ({
  endpoint: null,

  isLoading: false,
  error: null,

  designs: [],
  totalDesigns: 100,
  pageSize: null,
  currentPage: 1,

  searchFilter: '',
  currentFilterIndex: 0,
  filterStates: FILTER_STATES,
  filterOptions: Object.values(FILTER_STATES),
});
