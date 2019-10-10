import axios from '~/lib/utils/axios_utils';
import * as types from './mutation_types';

export const setSelectedGroup = ({ commit }, group) => commit(types.SET_SELECTED_GROUP, group);

export const setSelectedProject = ({ commit }, project) =>
  commit(types.SET_SELECTED_PROJECT, project);

export const setSelectedFileQuantity = ({ commit }, fileQuantity) =>
  commit(types.SET_SELECTED_FILE_QUANTITY, fileQuantity);

export const setEndpoint = ({ commit }, endpoint) => commit(types.SET_ENDPOINT, endpoint);

export const requestCodeHotspotsData = ({ commit }) => commit(types.REQUEST_CODE_HOTSPOTS_DATA);

export const receiveCodeHotspotsDataSuccess = ({ commit }, data) =>
  commit(types.RECEIVE_CODE_HOTSPOTS_DATA_SUCCESS, data);

export const receiveCodeHotspotsDataError = ({ commit }) =>
  commit(types.RECEIVE_CODE_HOTSPOTS_DATA_ERROR);

export const fetchCodeHotspotsData = ({ state, dispatch }) => {
  dispatch('requestCodeHotspotsData');

  axios
    .get(state.endpoint, {
      params: {
        group_id: state.selectedGroup.full_path,
        project_id: `${state.selectedGroup.full_path}/${state.selectedProject.path}`,
        file_count: state.selectedFileQuantity,
      },
    })
    .then(({ data }) => dispatch('receiveCodeHotspotsDataSuccess', data))
    .catch(error => dispatch('receiveCodeHotspotsDataError', error));
};

export default () => {};
