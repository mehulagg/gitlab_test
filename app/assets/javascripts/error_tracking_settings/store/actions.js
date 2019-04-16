import { __ } from '~/locale';
import axios from '~/lib/utils/axios_utils';
import { refreshCurrentPage } from '~/lib/utils/url_utility';
import createFlash from '~/flash';
import { transformFrontendSettings } from '../utils';
import * as types from './mutation_types';

export default {
  requestProjects: ({ commit }) => {
    commit(types.RESET_CONNECT);
  },

  receiveProjectsSuccess: ({ commit }, projects) => {
    commit(types.UPDATE_CONNECT_SUCCESS);
    commit(types.RECEIVE_PROJECTS, projects);
  },

  receiveProjectsError: ({ commit }) => {
    commit(types.UPDATE_CONNECT_ERROR);
    commit(types.CLEAR_PROJECTS);
  },

  fetchProjects: ({ dispatch, state }) => {
    dispatch('requestProjects');
    return axios
      .post(state.listProjectsEndpoint, {
        error_tracking_setting: {
          api_host: state.apiHost,
          token: state.token,
        },
      })
      .then(({ data: { projects } }) => {
        dispatch('receiveProjectsSuccess', projects);
      })
      .catch(() => {
        dispatch('receiveProjectsError');
      });
  },

  requestSettings: ({ commit }) => {
    commit(types.UPDATE_SETTINGS_LOADING, true);
  },

  receiveSettingsError: ({ commit }, { response = {} }) => {
    const message = response.data && response.data.message ? response.data.message : '';

    createFlash(`${__('There was an error saving your changes.')} ${message}`, 'alert');
    commit(types.UPDATE_SETTINGS_LOADING, false);
  },

  updateSettings: ({ dispatch, state }) => {
    dispatch('requestSettings');
    return axios
      .patch(state.operationsSettingsEndpoint, {
        project: {
          error_tracking_setting_attributes: {
            ...transformFrontendSettings(state),
          },
        },
      })
      .then(() => {
        refreshCurrentPage();
      })
      .catch(err => {
        dispatch('receiveSettingsError', err);
      });
  },

  updateApiHost: ({ commit }, apiHost) => {
    commit(types.UPDATE_API_HOST, apiHost);
    commit(types.RESET_CONNECT);
  },

  updateEnabled: ({ commit }, enabled) => {
    commit(types.UPDATE_ENABLED, enabled);
  },

  updateToken: ({ commit }, token) => {
    commit(types.UPDATE_TOKEN, token);
    commit(types.RESET_CONNECT);
  },

  updateSelectedProject: ({ commit }, selectedProject) => {
    commit(types.UPDATE_SELECTED_PROJECT, selectedProject);
  },

  setInitialState: ({ commit }, data) => {
    commit(types.SET_INITIAL_STATE, data);
  },
};
