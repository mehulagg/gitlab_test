import Visibility from 'visibilityjs';
import axios from '~/lib/utils/axios_utils';
import Poll from '~/lib/utils/poll';
import * as types from './mutation_types';
import httpStatusCodes from '~/lib/utils/http_status';

export const setEndpoint = ({ commit }, endpoint) => commit(types.SET_ENDPOINT, endpoint);

export const requestReport = ({ commit }) => commit(types.REQUEST_REPORT);

let eTagPoll;

export const clearEtagPoll = () => {
  eTagPoll = null;
};

export const stopPolling = () => {
  if (eTagPoll) eTagPoll.stop();
};

export const restartPolling = () => {
  if (eTagPoll) eTagPoll.restart();
};

/**
 * We need to poll the report endpoint while they are being parsed in the Backend.
 * This can take up to one minute.
 *
 * Poll.js will handle etag response.
 * While http status code is 204, it means it's parsing, and we'll keep polling
 * When http status code is 200, it means parsing is done, we can show the results & stop polling
 * When http status code is 500, it means parsing went wrong and we stop polling
 */
export const fetchReport = ({ state, dispatch }) => {
  dispatch('requestReport');

  eTagPoll = new Poll({
    resource: {
      getReport(endpoint) {
        return axios.get(endpoint);
      },
    },
    data: state.endpoint,
    method: 'getReport',
    successCallback: ({ data, status }) =>
      dispatch('receiveReportSuccess', {
        data,
        status,
      }),
    errorCallback: () => dispatch('receiveReportError'),
  });

  if (!Visibility.hidden()) {
    eTagPoll.makeRequest();
  } else {
    axios
      .get(state.endpoint)
      .then(({ data, status }) => dispatch('receiveReportSuccess', { data, status }))
      .catch(() => dispatch('receiveReportError'));
  }

  Visibility.change(() => {
    if (!Visibility.hidden()) {
      dispatch('restartPolling');
    } else {
      dispatch('stopPolling');
    }
  });
};

export const receiveReportSuccess = ({ commit }, response) => {
  // With 204 we keep polling and don't update the state
  if (response.status === httpStatusCodes.OK) {
    commit(types.RECEIVE_REPORT_SUCCESS, response.data);
  }
};

export const receiveReportError = ({ commit }) => commit(types.RECEIVE_REPORT_ERROR);

// prevent babel-plugin-rewire from generating an invalid default during karma tests
export default () => {};
