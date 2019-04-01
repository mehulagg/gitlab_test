import * as types from './mutation_types';

export default {
  [types.REQUEST_CONFIG](state) {
    state.configData = null;
    state.configLoading = true;
  },
  [types.RECEIVE_CONFIG_SUCCESS](state, data) {
    state.configData = data;
    state.configLoading = false;
  },
  [types.RECEIVE_CONFIG_ERROR](state) {
    state.configData = null;
    state.configLoading = false;
  },

  [types.RECEIVE_CHART_SUCCESS](state, { chart, data }) {
    const { store } = state;

    store[chart.title] = {
      type: chart.type,
      data,
      loaded: true,
    };
  },
  [types.RECEIVE_CHART_ERROR](state, { chart, error }) {
    const { store } = state;

    store[chart.title] = {
      type: chart.type,
      data: null,
      loaded: false,
      error,
    };
  },

  [types.SET_ACTIVE_TAB](state, tab) {
    state.activeTab = tab;
  },
  [types.SET_ACTIVE_PAGE](state, pageData) {
    state.activePage = pageData;
  },
  [types.SET_INSIGHTS_STORE](state, insightsStore) {
    state.store = insightsStore;
  },
  [types.SET_PAGE_LOADING](state, pageLoading) {
    state.pageLoading = pageLoading;
  },
};
