import { backOff } from '~/lib/utils/common_utils';
import httpStatusCodes from '~/lib/utils/http_status';
import axios from '~/lib/utils/axios_utils';
import flash from '~/flash';
import { s__ } from '~/locale';
import Api from 'ee/api';
import * as types from './mutation_types';

const requestLogsUntilData = ({ projectPath, cluster, namespace, podName }) =>
  backOff((next, stop) => {
    Api.getPodLogs({ projectPath, cluster, namespace, podName })
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

export const setInitData = (
  { dispatch, commit },
  { projectPath, filtersPath, cluster, podName, clusters },
) => {
  commit(types.SET_PROJECT_PATH, projectPath);
  commit(types.SET_FILTERS_PATH, filtersPath);
  commit(types.SET_CLUSTER_LIST, clusters);
  commit(types.SET_CLUSTER_NAME, cluster);
  commit(types.SET_CURRENT_POD_NAME, podName);
  dispatch('fetchFilters');
};

export const showPodLogs = ({ dispatch, commit }, podName) => {
  commit(types.SET_CURRENT_POD_NAME, podName);
  dispatch('fetchLogs');
};

export const showCluster = ({ dispatch, commit }, cluster) => {
  commit(types.SET_CLUSTER_NAME, cluster);
  commit(types.SET_CURRENT_POD_NAME, null);
  dispatch('fetchFilters');
};

export const fetchFilters = ({ dispatch, commit, state }) => {
  commit(types.REQUEST_FILTERS_DATA);

  axios
    .get(state.filtersPath, { params: { cluster: state.clusters.current } })
    .then(({ data }) => {
      commit(types.RECEIVE_FILTERS_DATA_SUCCESS, data);
      dispatch('fetchLogs');
    })
    .catch(error => {
      commit(types.RECEIVE_FILTERS_DATA_ERROR);
      flash(s__('Metrics|There was an error fetching the filter values, please try again'));
    });
};

export const fetchLogs = ({ commit, state }) => {
  const params = {
    projectPath: state.projectPath,
    cluster: state.clusters.current,
    podName: state.pods.current,
  };

  if (state.pods.current) {
    params.namespace = state.filters.data.pods.find(
      ({ name }) => name === state.pods.current,
    ).namespace;
  }

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
