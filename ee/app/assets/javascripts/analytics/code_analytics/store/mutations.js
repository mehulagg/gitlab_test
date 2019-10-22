import * as types from './mutation_types';

export default {
  [types.SET_SELECTED_GROUP](state, group) {
    state.selectedGroup = group;
    state.selectedProject = null;
  },
  [types.SET_SELECTED_PROJECT](state, project) {
    state.selectedProject = project;

    if (!project) {
      state.codeHotspotsData = [];
    }
  },
  [types.SET_SELECTED_FILE_QUANTITY](state, fileQuantity) {
    state.selectedFileQuantity = fileQuantity;
  },
  [types.SET_ENDPOINT](state, endpoint) {
    state.endpoint = endpoint;
  },
  [types.REQUEST_CODE_HOTSPOTS_DATA](state) {
    state.isLoading = true;
  },
  [types.RECEIVE_CODE_HOTSPOTS_DATA_SUCCESS](state, data) {
    const transformedData = data.map(item => ({
      value: item.count,
      ...item,
      link: `/${state.selectedGroup.path}/${state.selectedProject.path}/blob/master/${item.name}`,
    }));

    state.codeHotspotsData = transformedData;
    state.errorCode = null;
    state.isLoading = false;
  },
  [types.RECEIVE_CODE_HOTSPOTS_DATA_ERROR](state, errCode) {
    state.codeHotspotsData = [];
    state.errorCode = errCode;
    state.isLoading = false;
  },
};
