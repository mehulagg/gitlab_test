import * as types from './mutation_types';

export default {
  /** Project data */
  [types.SET_PROJECT_PATH](state, projectPath) {
    state.projectPath = projectPath;
  },

  /** Environments data */
  [types.SET_PROJECT_ENVIRONMENT](state, environmentName) {
    state.environments.current = environmentName;
  },
  [types.REQUEST_ENVIRONMENTS_DATA](state) {
    state.environments.options = [];
    state.environments.isLoading = true;
  },
  [types.RECEIVE_ENVIRONMENTS_DATA_SUCCESS](state, data) {
    state.environments.options = data;
    state.environments.isLoading = false;
  },
  [types.RECEIVE_ENVIRONMENTS_DATA_ERROR](state) {
    state.environments.options = [];
    state.environments.isLoading = false;
  },

  /** Logs data */
  [types.REQUEST_LOGS_DATA](state) {
    state.logs.lines = [];
    state.logs.isLoading = true;
    state.logs.isComplete = false;
  },
  [types.RECEIVE_LOGS_DATA_SUCCESS](state, lines) {
    state.logs.lines = lines;
    state.logs.isLoading = false;
    state.logs.isComplete = true;
  },
  [types.RECEIVE_LOGS_DATA_ERROR](state) {
    state.logs.lines = [];
    state.logs.isLoading = false;
    state.logs.isComplete = true;
  },

  /** Pods data */
  [types.SET_CURRENT_POD_NAME](state, podName) {
    state.pods.current = podName;
  },
  [types.REDRAW_POD_DROPDOWN](state) {
    state.pods.options = state.environments.options
      .find(env => env.name == state.environments.current)
      .pods.map(pod => pod.name);

    // current pod can be set on load by the ?pod_name= parameter
    // otherwise default to selecting the first in the list
    state.pods.current = state.pods.current || state.pods.options[0];
  },
};
