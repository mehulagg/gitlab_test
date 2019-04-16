import * as types from './mutation_types';
import axios from '~/lib/utils/axios_utils';

export default {
  setFeatureFlagsEndpoint: ({ commit }, endpoint) =>
    commit(types.SET_FEATURE_FLAGS_ENDPOINT, endpoint),

  setFeatureFlagsOptions: ({ commit }, options) => commit(types.SET_FEATURE_FLAGS_OPTIONS, options),

  fetchFeatureFlags: ({ state, dispatch }) => {
    dispatch('requestFeatureFlags');

    axios
      .get(state.endpoint, {
        params: state.options,
      })
      .then(response =>
        dispatch('receiveFeatureFlagsSuccess', {
          data: response.data || {},
          headers: response.headers,
        }),
      )
      .catch(() => dispatch('receiveFeatureFlagsError'));
  },

  requestFeatureFlags: ({ commit }) => commit(types.REQUEST_FEATURE_FLAGS),
  receiveFeatureFlagsSuccess: ({ commit }, response) =>
    commit(types.RECEIVE_FEATURE_FLAGS_SUCCESS, response),
  receiveFeatureFlagsError: ({ commit }) => commit(types.RECEIVE_FEATURE_FLAGS_ERROR),
};
