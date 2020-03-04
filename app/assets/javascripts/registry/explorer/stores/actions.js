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
import { decodeAndParse } from '../utils';

export const setInitialState = ({ commit }, data) => commit(types.SET_INITIAL_STATE, data);
export const setPage = ({ commit, state }, page) =>
  commit(types.SET_TAGS_PAGINATION, { ...state.tagsPagination, page });

export const setTagsSearch = ({ commit }, searchString) => {
  commit(types.SET_TAGS_SEARCH, searchString);
  commit(types.SET_TAGS_PAGINATION, {
    perPage: 10,
    page: 1,
  });
};

export const receiveImagesListSuccess = ({ commit }, { data, headers }) => {
  commit(types.SET_IMAGES_LIST_SUCCESS, data);
  commit(types.SET_PAGINATION, headers);
};

export const receiveImageDetailsSuccess = ({ commit }, data) => {
  commit(types.SET_TAGS_LIST_SUCCESS, data.tags);
  commit(types.SET_IMAGE_DETAILS, { ...data, tags: undefined });
  commit(types.SET_TAGS_PAGINATION, {
    perPage: 10,
    page: 1,
  });
};

export const receiveTagDetailsSuccess = ({ commit, state }, data) => {
  const tags = state.tags.map(t => (t.path === data.path ? data : t));
  commit(types.SET_TAGS_LIST_SUCCESS, tags);
};

export const setTagsSorting = ({ commit, state }, data) => {
  commit(types.SET_TAGS_SORTING, { ...state.tagsSorting, ...data });
};

export const requestImagesList = ({ commit, dispatch, state }, pagination = {}) => {
  commit(types.SET_MAIN_LOADING, true);
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
      commit(types.SET_MAIN_LOADING, false);
    });
};

export const requestImageDetails = ({ commit, dispatch, state }, id) => {
  commit(types.SET_MAIN_LOADING, true);
  commit(types.SET_AJAX_REQUESTS, {});
  return axios
    .get(`/api/v4/projects/${state.config.projectId}/registry/repositories/${id}`)
    .then(({ data }) => {
      dispatch('receiveImageDetailsSuccess', data);
    })
    .catch(() => {
      createFlash(FETCH_TAGS_LIST_ERROR_MESSAGE);
    })
    .finally(() => {
      commit(types.SET_MAIN_LOADING, false);
    });
};

export const requestTagDetails = ({ commit, dispatch, state }, name) => {
  if (state.tagsRequests[name]) {
    return state.tagsRequests[name];
  }

  const url = `/api/v4/projects/${state.imageDetails.project_id}/registry/repositories/${state.imageDetails.id}/tags/${name}`;

  const promise = axios
    .get(url)
    .then(({ data }) => {
      dispatch('receiveTagDetailsSuccess', data);
    })
    .catch(() => {
      createFlash(FETCH_TAGS_LIST_ERROR_MESSAGE);
    })
    .finally(() => {
      commit(types.SET_MAIN_LOADING, false);
    });
  commit(types.SET_AJAX_REQUESTS, { ...state.tagsRequests, [name]: promise });
  return promise;
};

export const requestDeleteTag = ({ commit, state }, { tag }) => {
  commit(types.SET_MAIN_LOADING, true);
  const url = `/api/v4/projects/${state.imageDetails.project_id}/registry/repositories/${state.imageDetails.id}/tags/${tag.name}`;
  return axios
    .delete(url)
    .then(() => {
      createFlash(DELETE_TAG_SUCCESS_MESSAGE, 'success');
      commit(types.SET_TAGS_LIST_SUCCESS, state.tags.filter(t => t.name !== tag.name));
    })
    .catch(() => {
      createFlash(DELETE_TAG_ERROR_MESSAGE);
    })
    .finally(() => {
      commit(types.SET_MAIN_LOADING, false);
    });
};

export const requestDeleteTags = ({ commit }, { ids, params }) => {
  commit(types.SET_MAIN_LOADING, true);
  const { tags_path } = decodeAndParse(params);

  const url = tags_path.replace('?format=json', '/bulk_destroy');

  return axios
    .delete(url, { params: { ids } })
    .then(() => {
      createFlash(DELETE_TAGS_SUCCESS_MESSAGE, 'success');
      // return dispatch('requestTagsList', { pagination: state.tagsPagination, params });
    })
    .catch(() => {
      createFlash(DELETE_TAGS_ERROR_MESSAGE);
      commit(types.SET_MAIN_LOADING, false);
    });
};

export const requestDeleteImage = ({ commit, dispatch, state }, destroyPath) => {
  commit(types.SET_MAIN_LOADING, true);

  return axios
    .delete(destroyPath)
    .then(() => {
      dispatch('requestImagesList', { pagination: state.pagination });
      createFlash(DELETE_IMAGE_SUCCESS_MESSAGE, 'success');
    })
    .catch(() => {
      createFlash(DELETE_IMAGE_ERROR_MESSAGE);
    })
    .finally(() => {
      commit(types.SET_MAIN_LOADING, false);
    });
};

export default () => {};
