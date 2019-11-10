import * as types from './mutation_types';
import createFlash from '~/flash';
import { __ } from '~/locale';
import api from '~/api';
import { getParameterByName, normalizeHeaders, parseIntPagination } from '~/lib/utils/common_utils';

/**
 * Commits a mutation to update the state while the main endpoint is being requested.
 */
export const requestReleases = ({ commit }) => commit(types.REQUEST_RELEASES);

/**
 * Fetches the main endpoint.
 * Will dispatch requestNamespace action before starting the request.
 * Will dispatch receiveNamespaceSuccess if the request is successful
 * Will dispatch receiveNamesapceError if the request returns an error
 *
 * @param {String} projectId
 */
export const fetchReleases = ({ dispatch }, projectId) => {
  const page = getParameterByName('page') || '1';

  dispatch('requestReleases');

  api
    .releases(projectId, { page: page })
    .then(response => dispatch('receiveReleasesSuccess', response))
    .catch(() => dispatch('receiveReleasesError'));
};

export const receiveReleasesSuccess = ({ commit }, resp) => {
  const data = resp.data;
  const pageInfo = parseIntPagination(normalizeHeaders(resp.headers));
  commit(types.RECEIVE_RELEASES_SUCCESS, { data, pageInfo });
};

export const receiveReleasesError = ({ commit }) => {
  commit(types.RECEIVE_RELEASES_ERROR);
  createFlash(__('An error occurred while fetching the releases. Please try again.'));
};

// prevent babel-plugin-rewire from generating an invalid default during karma tests
export default () => {};
