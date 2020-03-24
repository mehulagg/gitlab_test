import * as types from './mutation_types';

export default {
  [types.SET_SEARCH_QUERY](state, query) {
    state.searchQuery = query;
  },
  [types.CLEAR_SEARCH_RESULTS](state) {
    state.projectSearchResults = [];
    state.selectedProjects = [];
  },
  [types.REQUEST_SEARCH_RESULTS](state) {
    state.messages.minimumQuery = false;
    state.searchCount += 1;
  },
  [types.RECEIVE_SEARCH_RESULTS_SUCCESS](state, { data, pageInfo }) {
    state.projectSearchResults = data;
    state.pageInfo = pageInfo;

    state.messages.noResults = state.projectSearchResults.length === 0;
    state.messages.searchError = false;
    state.messages.minimumQuery = false;

    state.searchCount = Math.max(0, state.searchCount - 1);
  },
  [types.RECEIVE_SEARCH_RESULTS_ERROR](state) {
    state.projectSearchResults = [];

    state.messages.noResults = false;
    state.messages.searchError = true;
    state.messages.minimumQuery = false;

    state.searchCount = Math.max(0, state.searchCount - 1);
  },
  [types.SET_MINIMUM_QUERY_MESSAGE](state) {
    state.projectSearchResults = [];
    state.pageInfo.total = 0;

    state.messages.noResults = false;
    state.messages.searchError = false;
    state.messages.minimumQuery = true;

    state.searchCount = Math.max(0, state.searchCount - 1);
  },
  [types.RECEIVE_NEXT_PAGE_SUCCESS](state, { data, pageInfo }) {
    state.projectSearchResults = state.projectSearchResults.concat(data);

    state.pageInfo = pageInfo;
  },
};
