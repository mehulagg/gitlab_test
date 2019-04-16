import * as types from './mutation_types';
import createFlash from '~/flash';
import { __ } from '~/locale';
import api from '~/api';

/**
 * Commits a mutation to update the state while the main endpoint is being requested.
 */
export default {
  requestReleases: ({ commit }) => commit(types.REQUEST_RELEASES),

  /**
   * Fetches the main endpoint.
   * Will dispatch requestNamespace action before starting the request.
   * Will dispatch receiveNamespaceSuccess if the request is successful
   * Will dispatch receiveNamesapceError if the request returns an error
   *
   * @param {String} projectId
   */
  fetchReleases: ({ dispatch }, projectId) => {
    dispatch('requestReleases');

    api
      .releases(projectId)
      .then(({ data }) => dispatch('receiveReleasesSuccess', data))
      .catch(() => dispatch('receiveReleasesError'));
  },

  receiveReleasesSuccess: ({ commit }, data) => commit(types.RECEIVE_RELEASES_SUCCESS, data),

  receiveReleasesError: ({ commit }) => {
    commit(types.RECEIVE_RELEASES_ERROR);
    createFlash(__('An error occurred while fetching the releases. Please try again.'));
  },
};
