import { __ } from '../../../../locale';
import Api from '../../../../api';
import { scopes } from './constants';
import * as types from './mutation_types';

export default {
  requestMergeRequests: ({ commit }) => commit(types.REQUEST_MERGE_REQUESTS),
  receiveMergeRequestsError: ({ commit, dispatch }, { type, search }) => {
    dispatch(
      'setErrorMessage',
      {
        text: __('Error loading merge requests.'),
        action: payload =>
          dispatch('fetchMergeRequests', payload).then(() =>
            dispatch('setErrorMessage', null, { root: true }),
          ),
        actionText: __('Please try again'),
        actionPayload: { type, search },
      },
      { root: true },
    );
    commit(types.RECEIVE_MERGE_REQUESTS_ERROR);
  },
  receiveMergeRequestsSuccess: ({ commit }, data) =>
    commit(types.RECEIVE_MERGE_REQUESTS_SUCCESS, data),

  fetchMergeRequests: (
    { dispatch, state: { state }, rootState: { currentProjectId } },
    { type, search = '' },
  ) => {
    dispatch('requestMergeRequests');
    dispatch('resetMergeRequests');

    const scope = type && scopes[type];
    const request = scope
      ? Api.mergeRequests({ scope, state, search })
      : Api.projectMergeRequest(currentProjectId, '', { state, search });

    return request
      .then(({ data }) => dispatch('receiveMergeRequestsSuccess', data))
      .catch(() => dispatch('receiveMergeRequestsError', { type, search }));
  },

  resetMergeRequests: ({ commit }) => commit(types.RESET_MERGE_REQUESTS),
};
