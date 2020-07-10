import axios from '~/lib/utils/axios_utils';
import createFlash from '~/flash';
import { __ } from '~/locale';
import * as types from './mutation_types';

export const requestChartSeriesData = ({ commit }) => commit(types.REQUEST_CHART_SERIES_DATA);

export const receiveChartSeriesDataSuccess = ({ commit }, data) =>
  commit(types.RECEIVE_CHART_SERIES_DATA_SUCCESS, data);

export const receiveChartSeriesDataError = ({ commit }) => {
  commit(types.RECEIVE_CHART_SERIES_DATA_ERROR);
  createFlash(__('There was an error while fetching chart series data.'));
};

export const fetchChartSeriesData = ({ dispatch, rootState }) => {
  dispatch('requestChartSeriesData');

  const {
    page: {
      reportId,
      seriesEndpoint,
      config: {
        chart: { series },
      },
    },
  } = rootState;
  const { id: seriesId } = series[0];

  return axios
    .get(seriesEndpoint.replace('REPORT_ID', reportId).replace('SERIES_ID', seriesId))
    .then(response => {
      const { data } = response;
      dispatch('receiveChartSeriesDataSuccess', data);
    })
    .catch(() => dispatch('receiveChartSeriesDataError'));
};
