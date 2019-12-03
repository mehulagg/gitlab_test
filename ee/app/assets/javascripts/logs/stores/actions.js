import Api from 'ee/api';
import { backOff } from '~/lib/utils/common_utils';
import httpStatusCodes from '~/lib/utils/http_status';
import axios from '~/lib/utils/axios_utils';
import flash from '~/flash';
import { s__ } from '~/locale';
import * as types from './mutation_types';

const requestLogsUntilData = ({ projectPath, environmentName, podName }) =>
  backOff((next, stop) => {
    Api.getPodLogs({ projectPath, environmentName, podName })
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
  { projectPath, environmentsPath, environmentName, podName },
) => {
  commit(types.SET_PROJECT_PATH, projectPath);
  commit(types.SET_PROJECT_ENVIRONMENT, environmentName);
  commit(types.SET_CURRENT_POD_NAME, podName);
  dispatch('fetchEnvironments', environmentsPath);
};

export const showPodLogs = ({ dispatch, commit, state }, podName) => {
  if (state.pods.current == podName) {
    return;
  }
  commit(types.SET_CURRENT_POD_NAME, podName);
  dispatch('fetchLogs');
};

export const showEnvironment = ({ dispatch, commit, state }, environmentName) => {
  if (state.environments.current == environmentName) {
    return;
  }
  commit(types.SET_PROJECT_ENVIRONMENT, environmentName);
  commit(types.SET_CURRENT_POD_NAME, null);
  commit(types.REDRAW_POD_DROPDOWN);
  dispatch('fetchLogs');
};

export const fetchEnvironments = ({ commit, dispatch }, environmentsPath) => {
  commit(types.REQUEST_ENVIRONMENTS_DATA);

  axios
    .get(environmentsPath)
    .then(({ data }) => {
      commit(types.RECEIVE_ENVIRONMENTS_DATA_SUCCESS, data);
      commit(types.REDRAW_POD_DROPDOWN);
      dispatch('fetchLogs');
    })
    .catch(() => {
      commit(types.RECEIVE_ENVIRONMENTS_DATA_ERROR);
      flash(s__('Metrics|There was an error fetching the environments data, please try again'));
    });
};

export const fetchLogs = ({ commit, state }) => {
  const params = {
    projectPath: state.projectPath,
    environmentName: state.environments.current,
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
