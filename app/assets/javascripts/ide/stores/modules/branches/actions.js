import { __ } from '~/locale';
import Api from '~/api';
import * as types from './mutation_types';

export default {
  requestBranches: ({ commit }) => commit(types.REQUEST_BRANCHES),
  receiveBranchesError: ({ commit, dispatch }, { search }) => {
    dispatch(
      'setErrorMessage',
      {
        text: __('Error loading branches.'),
        action: payload =>
          dispatch('fetchBranches', payload).then(() =>
            dispatch('setErrorMessage', null, { root: true }),
          ),
        actionText: __('Please try again'),
        actionPayload: { search },
      },
      { root: true },
    );
    commit(types.RECEIVE_BRANCHES_ERROR);
  },
  receiveBranchesSuccess: ({ commit }, data) => commit(types.RECEIVE_BRANCHES_SUCCESS, data),

  fetchBranches: ({ dispatch, rootGetters }, { search = '' }) => {
    dispatch('requestBranches');
    dispatch('resetBranches');

    return Api.branches(rootGetters.currentProject.id, search, { sort: 'updated_desc' })
      .then(({ data }) => dispatch('receiveBranchesSuccess', data))
      .catch(() => dispatch('receiveBranchesError', { search }));
  },

  resetBranches: ({ commit }) => commit(types.RESET_BRANCHES),
};
