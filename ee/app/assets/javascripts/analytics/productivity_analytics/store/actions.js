import * as types from './mutation_types';

export const setChartEndpoint = ({ commit }, endpoint) =>
  commit(types.SET_CHART_ENDPOINT, endpoint);

export const requestChartData = ({ commit }) => commit(types.REQUEST_CHART_DATA);

export const fetchChartData = ({ state, dispatch }) => {
  dispatch('requestChartData');

  const data = {
    1: '2',
    2: '3',
    3: '4',
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
