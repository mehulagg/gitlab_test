import { backOff } from '~/lib/utils/common_utils';
import httpStatusCodes from '~/lib/utils/http_status';
import axios from '~/lib/utils/axios_utils';
import flash from '~/flash';
import { s__ } from '~/locale';
import Api from 'ee/api';
import * as types from './mutation_types';

const requestLogsUntilData = ({ projectPath, clusterName, podName }) =>
  backOff((next, stop) => {
    Api.getPodLogs({ projectPath, clusterName, podName })
      .then(res => {
        if (res.status === httpStatusCodes.ACCEPTED) {
          next();
          return;
        }
        stop(res);
      })
      .catch(err => {
        stop(err);
      });
  });

export const setInitData = ({ dispatch, commit }, { projectPath, clusterName, podName }) => {
  commit(types.SET_PROJECT_PATH, projectPath);
  commit(types.SET_CLUSTER_NAME, clusterName);
  commit(types.SET_POD_NAME, podName);
  dispatch('fetchLogs');
};

export const showPodLogs = ({ dispatch, commit }, podName) => {
  commit(types.SET_POD_NAME, podName);
  dispatch('fetchLogs');
};

export const showCluster = ({ dispatch, commit }, clusterName) => {
  commit(types.SET_CLUSTER_NAME, clusterName);
  commit(types.SET_POD_NAME, null);
  dispatch('fetchLogs');
};

export const fetchFilters = ({ commit }, filtersPath) => {
  commit(types.REQUEST_FILTERS_DATA);

  axios
    .get(filtersPath)
    .then(({ data }) => {
      commit(types.RECEIVE_FILTERS_DATA_SUCCESS, data);
    })
    .catch(() => {
      commit(types.RECEIVE_FILTERS_DATA_ERROR);
      flash(s__('Metrics|There was an error fetching the filter values, please try again'));
    });
};

export const fetchLogs = ({ commit, state }) => {
  const params = {
    projectPath: state.projectPath,
    clusterName: state.selectedCluster,
    podName: state.pods.current,
  };

  commit(types.REQUEST_LOGS_DATA);

  return requestLogsUntilData(params)
    .then(({ data }) => {
      commit(types.RECEIVE_LOGS_DATA_SUCCESS, data.logs);
    })
    .catch(() => {
      commit(types.RECEIVE_LOGS_DATA_ERROR);
      flash(s__('Metrics|There was an error fetching the logs, please try again'));
    });
};

// prevent babel-plugin-rewire from generating an invalid default during karma tests
export default () => {};
