import Api from '~/api';
import AccessorUtilities from '~/lib/utils/accessor';
import * as types from './mutation_types';
import { getTopFrequentItems } from '../utils';

export default {
  setNamespace: ({ commit }, namespace) => {
    commit(types.SET_NAMESPACE, namespace);
  },

  setStorageKey: ({ commit }, key) => {
    commit(types.SET_STORAGE_KEY, key);
  },

  requestFrequentItems: ({ commit }) => {
    commit(types.REQUEST_FREQUENT_ITEMS);
  },
  receiveFrequentItemsSuccess: ({ commit }, data) => {
    commit(types.RECEIVE_FREQUENT_ITEMS_SUCCESS, data);
  },
  receiveFrequentItemsError: ({ commit }) => {
    commit(types.RECEIVE_FREQUENT_ITEMS_ERROR);
  },

  fetchFrequentItems: ({ state, dispatch }) => {
    dispatch('requestFrequentItems');

    if (AccessorUtilities.isLocalStorageAccessSafe()) {
      const storedFrequentItems = JSON.parse(localStorage.getItem(state.storageKey));

      dispatch(
        'receiveFrequentItemsSuccess',
        !storedFrequentItems ? [] : getTopFrequentItems(storedFrequentItems),
      );
    } else {
      dispatch('receiveFrequentItemsError');
    }
  },

  requestSearchedItems: ({ commit }) => {
    commit(types.REQUEST_SEARCHED_ITEMS);
  },
  receiveSearchedItemsSuccess: ({ commit }, data) => {
    commit(types.RECEIVE_SEARCHED_ITEMS_SUCCESS, data);
  },
  receiveSearchedItemsError: ({ commit }) => {
    commit(types.RECEIVE_SEARCHED_ITEMS_ERROR);
  },
  fetchSearchedItems: ({ state, dispatch }, searchQuery) => {
    dispatch('requestSearchedItems');

    const params = {
      simple: true,
      per_page: 20,
      membership: !!gon.current_user_id,
    };

    if (state.namespace === 'projects') {
      params.order_by = 'last_activity_at';
    }

    return Api[state.namespace](searchQuery, params)
      .then(results => {
        dispatch('receiveSearchedItemsSuccess', results);
      })
      .catch(() => {
        dispatch('receiveSearchedItemsError');
      });
  },

  setSearchQuery: ({ commit, dispatch }, query) => {
    commit(types.SET_SEARCH_QUERY, query);

    if (query) {
      dispatch('fetchSearchedItems', query);
    } else {
      dispatch('fetchFrequentItems');
    }
  },
};
