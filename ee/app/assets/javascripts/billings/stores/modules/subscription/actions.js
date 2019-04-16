import API from 'ee/api';
import * as types from './mutation_types';
import createFlash from '~/flash';
import { __ } from '~/locale';

/**
 * SUBSCRIPTION TABLE
 */
export default {
  setNamespaceId: ({ commit }, namespaceId) => {
    commit(types.SET_NAMESPACE_ID, namespaceId);
  },

  fetchSubscription: ({ dispatch, state }) => {
    dispatch('requestSubscription');

    return API.userSubscription(state.namespaceId)
      .then(({ data }) => dispatch('receiveSubscriptionSuccess', data))
      .catch(() => dispatch('receiveSubscriptionError'));
  },

  requestSubscription: ({ commit }) => commit(types.REQUEST_SUBSCRIPTION),

  receiveSubscriptionSuccess: ({ commit }, response) =>
    commit(types.RECEIVE_SUBSCRIPTION_SUCCESS, response),

  receiveSubscriptionError: ({ commit }) => {
    createFlash(__('An error occurred while loading the subscription details.'));
    commit(types.RECEIVE_SUBSCRIPTION_ERROR);
  },
};
