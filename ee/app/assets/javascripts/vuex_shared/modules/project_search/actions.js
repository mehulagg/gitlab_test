import Api from '~/api';
import addPageInfo from './utils/add_page_info';
import * as types from './mutation_types';

const API_MINIMUM_QUERY_LENGTH = 3;

const searchProjects = (searchQuery, searchOptions) =>
  Api.projects(searchQuery, searchOptions).then(addPageInfo);

export const clearSearchResults = ({ commit }) => {
  commit(types.CLEAR_SEARCH_RESULTS);
};

export const setSearchQuery = ({ commit }, query) => {
  commit(types.SET_SEARCH_QUERY, query);
};

export const fetchSearchResults = ({ state, dispatch, commit }) => {
  const { searchQuery } = state;
  dispatch('requestSearchResults');

  if (!searchQuery || searchQuery.length < API_MINIMUM_QUERY_LENGTH) {
    return dispatch('setMinimumQueryMessage');
  }

  return searchProjects(searchQuery)
    .then(payload => commit(types.RECEIVE_SEARCH_RESULTS_SUCCESS, payload))
    .catch(() => dispatch('receiveSearchResultsError'));
};

export const fetchSearchResultsNextPage = ({ state, dispatch, commit }) => {
  const {
    searchQuery,
    pageInfo: { totalPages, page, nextPage },
  } = state;

  if (totalPages <= page) {
    return Promise.resolve();
  }

  const searchOptions = { page: nextPage };

  return searchProjects(searchQuery, searchOptions)
    .then(payload => {
      commit(types.RECEIVE_NEXT_PAGE_SUCCESS, payload);
    })
    .catch(() => dispatch('receiveSearchResultsError'));
};

export const requestSearchResults = ({ commit }) => {
  commit(types.REQUEST_SEARCH_RESULTS);
};

export const receiveSearchResultsError = ({ commit }) => {
  commit(types.RECEIVE_SEARCH_RESULTS_ERROR);
};

export const setMinimumQueryMessage = ({ commit }) => {
  commit(types.SET_MINIMUM_QUERY_MESSAGE);
};

export default () => {};
