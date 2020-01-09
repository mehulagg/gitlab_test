import axios from '~/lib/utils/axios_utils';
import createFlash from '~/flash';
import * as types from './mutation_types';
import {
  FETCH_IMAGES_LIST_ERROR_MESSAGE,
  DEFAULT_PAGE,
  DEFAULT_PAGE_SIZE,
  FETCH_TAGS_LIST_ERROR_MESSAGE,
  DELETE_TAG_SUCCESS_MESSAGE,
  DELETE_TAG_ERROR_MESSAGE,
  DELETE_TAGS_SUCCESS_MESSAGE,
  DELETE_TAGS_ERROR_MESSAGE,
  DELETE_IMAGE_ERROR_MESSAGE,
  DELETE_IMAGE_SUCCESS_MESSAGE,
} from '../constants';

export const setInitialState = ({ commit }, data) => commit(types.SET_INITIAL_STATE, data);
export const setLoading = ({ commit }, data) => commit(types.SET_MAIN_LOADING, data);

export const receiveImagesListSuccess = ({ commit }, { data, headers }) => {
  commit(types.SET_IMAGES_LIST_SUCCESS, data);
  commit(types.SET_PAGINATION, headers);
};

export const receiveTagsListSuccess = ({ commit }, { data, headers }) => {
  commit(types.SET_TAGS_LIST_SUCCESS, data);
  commit(types.SET_TAGS_PAGINATION, headers);
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

export const requestTagsList = ({ dispatch }, { pagination = {}, id }) => {
  dispatch('setLoading', true);
  const url = window.atob(id);

  const { page = DEFAULT_PAGE, perPage = DEFAULT_PAGE_SIZE } = pagination;
  return axios
    .get(url, { params: { page, per_page: perPage } })
    .then(({ data, headers }) => {
      dispatch('receiveTagsListSuccess', { data, headers });
    })
    .catch(() => {
      createFlash(FETCH_TAGS_LIST_ERROR_MESSAGE);
    })
    .finally(() => {
      dispatch('setLoading', false);
    });
};

export const requestDeleteTag = ({ dispatch, state }, { tag, imageId }) => {
  dispatch('setLoading', true);
  return axios
    .delete(tag.destroy_path)
    .then(() => {
      createFlash(DELETE_TAG_SUCCESS_MESSAGE, 'success');
      dispatch('requestTagsList', { pagination: state.tagsPagination, id: imageId });
    })
    .catch(() => {
      createFlash(DELETE_TAG_ERROR_MESSAGE);
    })
    .finally(() => {
      dispatch('setLoading', false);
    });
};

export const requestDeleteTags = ({ dispatch, state }, { ids, imageId }) => {
  dispatch('setLoading', true);
  const url = `/${state.config.projectPath}/registry/repository/${imageId}/tags/bulk_destroy`;

  return axios
    .delete(url, { params: { ids } })
    .then(() => {
      createFlash(DELETE_TAGS_SUCCESS_MESSAGE, 'success');
      dispatch('requestTagsList', { pagination: state.tagsPagination, id: imageId });
    })
    .catch(() => {
      createFlash(DELETE_TAGS_ERROR_MESSAGE);
    })
    .finally(() => {
      dispatch('setLoading', false);
    });
};

export const requestDeleteImage = ({ dispatch, state }, destroyPath) => {
  dispatch('setLoading', true);
  return axios
    .delete(destroyPath)
    .then(() => {
      dispatch('requestImagesList', { pagination: state.pagination });
      createFlash(DELETE_IMAGE_SUCCESS_MESSAGE, 'success');
    })
    .catch(e => {
      console.log(e);
      createFlash(DELETE_IMAGE_ERROR_MESSAGE);
    })
    .finally(() => {
      dispatch('setLoading', false);
    });
};

export default () => {};
