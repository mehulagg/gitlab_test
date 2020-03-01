import { s__ } from '~/locale';
import pollUntilComplete from '~/lib/utils/poll_until_complete';
import httpStatusCodes from '~/lib/utils/http_status';
import createFlash from '~/flash';
import * as types from './mutation_types';
import createState from './state';
import { getTimeWindowParams } from '../../utils';

export const requestStatistics = ({ commit }) => commit(types.REQUEST_STATISTICS);
export const receiveStatisticsSuccess = ({ commit }, statistics) =>
  commit(types.RECEIVE_STATISTICS_SUCCESS, statistics);
export const receiveStatisticsError = ({ commit }) => {
  commit(types.RECEIVE_STATISTICS_ERROR);
  createFlash(s__('ThreatMonitoring|Something went wrong, unable to fetch statistics'));
};

export const fetchStatistics = ({ state, dispatch, rootState }) => {
  const { currentEnvironmentId, currentTimeWindow } = rootState.threatMonitoring;

  if (!state.statisticsEndpoint) {
    return dispatch('receiveStatisticsError');
  }

  dispatch('requestStatistics');

  return pollUntilComplete(state.statisticsEndpoint, {
    params: {
      environment_id: currentEnvironmentId,
      ...getTimeWindowParams(currentTimeWindow, Date.now()),
    },
  })
    .then(({ data }) => dispatch('receiveStatisticsSuccess', data))
    .catch(error => {
      // A NOT_FOUND response from the endpoint means that there is no data for
      // the given parameters. There are various reasons *why* there could be
      // no data, but we can't distinguish between them, yet. So, just render
      // no data.
      if (error.response.status === httpStatusCodes.NOT_FOUND) {
        dispatch('receiveStatisticsSuccess', createState().statistics);
      } else {
        dispatch('receiveStatisticsError');
      }
    });
};
