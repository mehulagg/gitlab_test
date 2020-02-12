import service from '../../services';
import * as types from './mutation_types';
import createFlash from '~/flash';
import Poll from '~/lib/utils/poll';
import { __ } from '~/locale';
import axios from '../../../lib/utils/axios_utils';

let stackTracePoll;

const stopPolling = poll => {
  if (poll) poll.stop();
};

export function startPollingStacktrace({ commit }, endpoint) {
  stackTracePoll = new Poll({
    resource: service,
    method: 'getSentryData',
    data: { endpoint },
    successCallback: ({ data }) => {
      if (!data) {
        return;
      }
      commit(types.SET_STACKTRACE_DATA, data.error);
      commit(types.SET_LOADING_STACKTRACE, false);

      stopPolling(stackTracePoll);
    },
    errorCallback: () => {
      commit(types.SET_LOADING_STACKTRACE, false);
      createFlash(__('Failed to load stacktrace.'));
    },
  });

  stackTracePoll.makeRequest();
}

export const renderMarkdown = ({ commit }, { endpoint, payload }) => {
  commit(types.REQUEST_ISSUE_MARKDOWN);
  return axios
    .post(endpoint, { text: payload })
    .then(({ data }) => {
      commit(types.RECEIVE_ISSUE_MARKDOWN_SUCCESS, data.body);
    })
    .catch(() => {
      commit(types.RECEIVE_ISSUE_MARKDOWN_ERROR);
    });
};

export default () => {};
