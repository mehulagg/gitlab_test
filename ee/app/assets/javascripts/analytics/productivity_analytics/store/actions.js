import * as types from './mutation_types';

export const setChartEndpoint = ({ commit }, endpoint) =>
  commit(types.SET_CHART_ENDPOINT, endpoint);

export const setGroupId = ({ commit, dispatch }, groupId) => {
  commit(types.SET_GROUP_ID, groupId);

  dispatch('fetchChartData');
};

export const requestChartData = ({ commit }) => commit(types.REQUEST_CHART_DATA);

export const fetchChartData = ({ state, dispatch }) => {
  dispatch('requestChartData');

  const data = {
    1: '1',
    2: '2',
    3: '3',
    4: '4',
    5: '5',
    6: '6',
    7: '7',
    8: '8',
    9: '9',
    10: '10',
    11: '11',
    12: '12',
    13: '13',
    14: '14',
    15: '15',
  };

  setTimeout(() => {
    dispatch('receiveChartDataSuccess', data);
  }, 2000);
};

export const receiveChartDataSuccess = ({ commit }, data = {}) => {
  commit(types.RECEIVE_CHART_DATA_SUCCESS, data);
};

export const receiveChartDataError = ({ commit }) => {
  commit(types.RECEIVE_CHART_DATA_ERROR);
};

export const setMetricType = ({ commit }, data = {}) => {
  commit(types.SET_METRIC_TYPE, data);
};
