import * as types from './mutation_types';

export default {
  [types.SET_PACKAGE](state, data) {
    state.package = data;
  },

  [types.SET_PROJECT_ID](state, data) {
    state.projectId = data;
  },

  [types.SET_SELECTED_PROJECT](state, data) {
    state.selectedProject = data;
  },

  [types.SET_BRANCH_NAME](state, data) {
    state.branchName = data;
  },

  [types.SET_LOADING](state) {
    state.isLoading = !state.isLoading;
  },
};
