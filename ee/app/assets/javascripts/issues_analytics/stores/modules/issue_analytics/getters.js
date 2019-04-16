export default {
  hasFilters: state => Object.keys(state.filters).length > 0,
  appliedFilters: state => state.filters,
};
