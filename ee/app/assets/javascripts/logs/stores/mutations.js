import * as types from './mutation_types';

export default {
  /** Project data */
  [types.SET_PROJECT_PATH](state, projectPath) {
    state.projectPath = projectPath;
  },

  /** Clusters data */
  [types.SET_CLUSTER_NAME](state, clusterName) {
    state.selectedCluster = clusterName;
  },
  [types.REQUEST_FILTERS_DATA](state) {
    state.filters.data = [];
    state.filters.isLoading = true;
  },
  [types.RECEIVE_FILTERS_DATA_SUCCESS](state, data) {
    state.filters.data = data;
    state.filters.isLoading = false;

    state.pods.options = data.pods.map(pod => pod.name)
  },
  [types.RECEIVE_FILTERS_DATA_ERROR](state) {
    state.filters.data = [];
    state.filters.isLoading = false;
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
  [types.SET_POD_NAME](state, podName) {
    state.pods.current = podName;
  },
};
