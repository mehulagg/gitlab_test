import * as types from './mutation_types';
import axios from '~/lib/utils/axios_utils';
import { visitUrl } from '~/lib/utils/url_utility';
import { parseFeatureFlagsParams } from '../helpers';

/**
 * Commits mutation to set the main endpoint
 * @param {String} endpoint
 */
export default {
  setEndpoint: ({ commit }, endpoint) => commit(types.SET_ENDPOINT, endpoint),

  /**
   * Commits mutation to set the feature flag path.
   * Used to redirect the user after form submission
   *
   * @param {String} path
   */
  setPath: ({ commit }, path) => commit(types.SET_PATH, path),

  /**
   * Handles the creation of a new feature flag.
   *
   * Will dispatch `requestCreateFeatureFlag`
   * Serializes the params and makes a post request
   * Dispatches an action acording to the request status.
   *
   * @param {Object} params
   */
  createFeatureFlag: ({ state, dispatch }, params) => {
    dispatch('requestCreateFeatureFlag');

    axios
      .post(state.endpoint, parseFeatureFlagsParams(params))
      .then(() => {
        dispatch('receiveCreateFeatureFlagSuccess');
        visitUrl(state.path);
      })
      .catch(error => dispatch('receiveCreateFeatureFlagError', error.response.data));
  },

  requestCreateFeatureFlag: ({ commit }) => commit(types.REQUEST_CREATE_FEATURE_FLAG),
  receiveCreateFeatureFlagSuccess: ({ commit }) =>
    commit(types.RECEIVE_CREATE_FEATURE_FLAG_SUCCESS),
  receiveCreateFeatureFlagError: ({ commit }, error) =>
    commit(types.RECEIVE_CREATE_FEATURE_FLAG_ERROR, error),
};
