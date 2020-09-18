import * as types from './mutation_types';

export const fetchSearch = ({ commit }) => {
  commit(types.REQUEST_SEARCH);

  /*
  This is an example of what the search would look like
  1. Pass query in and call API method
  2. Handle Success/Error via the mutations

  Api.globalSearch(state.query)
    .then(({ data }) => {
      commit(types.RECEIVE_SEARCH_SUCCESS, data);
    })
    .catch(() => {
      createFlash(__('There was an error fetching the your search!'));
      commit(types.RECEIVE_SEARCH_ERROR);
    });
    */
};
