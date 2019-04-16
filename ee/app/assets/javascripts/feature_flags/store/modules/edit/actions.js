import * as types from './mutation_types';
import axios from '~/lib/utils/axios_utils';
import { visitUrl } from '~/lib/utils/url_utility';
import createFlash from '~/flash';
import { __ } from '~/locale';
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
   * Handles the edition of a feature flag.
   *
   * Will dispatch `requestUpdateFeatureFlag`
   * Serializes the params and makes a put request
   * Dispatches an action acording to the request status.
   *
   * @param {Object} params
   */
  updateFeatureFlag: ({ state, dispatch }, params) => {
    dispatch('requestUpdateFeatureFlag');

    axios
      .put(state.endpoint, parseFeatureFlagsParams(params))
      .then(() => {
        dispatch('receiveUpdateFeatureFlagSuccess');
        visitUrl(state.path);
      })
      .catch(error => dispatch('receiveUpdateFeatureFlagError', error.response.data));
  },

  requestUpdateFeatureFlag: ({ commit }) => commit(types.REQUEST_UPDATE_FEATURE_FLAG),
  receiveUpdateFeatureFlagSuccess: ({ commit }) =>
    commit(types.RECEIVE_UPDATE_FEATURE_FLAG_SUCCESS),
  receiveUpdateFeatureFlagError: ({ commit }, error) =>
    commit(types.RECEIVE_UPDATE_FEATURE_FLAG_ERROR, error),

  /**
   * Fetches the feature flag data for the edit form
   */
  fetchFeatureFlag: ({ state, dispatch }) => {
    dispatch('requestFeatureFlag');

    axios
      .get(state.endpoint)
      .then(({ data }) => dispatch('receiveFeatureFlagSuccess', data))
      .catch(() => dispatch('receiveFeatureFlagError'));
  },

  requestFeatureFlag: ({ commit }) => commit(types.REQUEST_FEATURE_FLAG),
  receiveFeatureFlagSuccess: ({ commit }, response) =>
    commit(types.RECEIVE_FEATURE_FLAG_SUCCESS, response),
  receiveFeatureFlagError: ({ commit }) => {
    commit(types.RECEIVE_FEATURE_FLAG_ERROR);
    createFlash(__('Something went wrong on our end. Please try again!'));
  },
};
