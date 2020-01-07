import axios from '~/lib/utils/axios_utils';
import createFlash from '~/flash';
import * as types from './mutation_types';
import { FETCH_IMAGES_LIST_ERROR_MESSAGE, DEFAULT_PAGE, DEFAULT_PAGE_SIZE } from '../constants';

export const setInitialState = ({ commit }, data) => commit(types.SET_INITIAL_STATE, data);
export const setLoading = ({ commit }, data) => commit(types.SET_MAIN_LOADING, data);

export const receiveImagesListSuccess = ({ commit }, { data, headers }) => {
  commit(types.SET_IMAGES_LIST_SUCCESS, data);
  commit(types.SET_PAGINATION, headers);
};

export const requestImagesList = ({ dispatch, state }, pagination = {}) => {
  dispatch('setLoading', true);

  const { page = DEFAULT_PAGE, perPage = DEFAULT_PAGE_SIZE } = pagination;
  return axios
    .get(state.config.endpoint, { params: { page, per_page: perPage } })
    .then(({ data, headers }) => {
      dispatch('receiveImagesListSuccess', { data, headers });
    })
    .catch(() => {
      createFlash(FETCH_IMAGES_LIST_ERROR_MESSAGE);
    })
    .finally(() => {
      dispatch('setLoading', false);
    });
};

// export const requestDeleteImage = ({ dispatch }, { projectId, packageId }) => {
//   dispatch('setLoading', true);
//   return Api.deleteProjectPackage(projectId, packageId)
//     .then(() => {
//       dispatch('requestImagesList');
//       createFlash(DELETE_PACKAGE_SUCCESS_MESSAGE, 'success');
//     })
//     .catch(() => {
//       createFlash(DELETE_PACKAGE_ERROR_MESSAGE);
//     })
//     .finally(() => {
//       dispatch('setLoading', false);
//     });
// };

export default () => {};
