import axios from '~/lib/utils/axios_utils';
import createFlash from '~/flash';
import * as types from './mutation_types';
import { errorMessages, errorMessagesTypes } from '../constants';

export default {
  fetchRepos: ({ commit, state }) => {
    commit(types.TOGGLE_MAIN_LOADING);

    return axios
      .get(state.endpoint)
      .then(({ data }) => {
        commit(types.TOGGLE_MAIN_LOADING);
        commit(types.SET_REPOS_LIST, data);
      })
      .catch(() => {
        commit(types.TOGGLE_MAIN_LOADING);
        createFlash(errorMessages[errorMessagesTypes.FETCH_REPOS]);
      });
  },

  fetchList: ({ commit }, { repo, page }) => {
    commit(types.TOGGLE_REGISTRY_LIST_LOADING, repo);

    return axios
      .get(repo.tagsPath, { params: { page } })
      .then(response => {
        const { headers, data } = response;

        commit(types.TOGGLE_REGISTRY_LIST_LOADING, repo);
        commit(types.SET_REGISTRY_LIST, { repo, resp: data, headers });
      })
      .catch(() => {
        commit(types.TOGGLE_REGISTRY_LIST_LOADING, repo);
        createFlash(errorMessages[errorMessagesTypes.FETCH_REGISTRY]);
      });
  },

  // eslint-disable-next-line no-unused-vars
  deleteRepo: ({ commit }, repo) => axios.delete(repo.destroyPath),

  // eslint-disable-next-line no-unused-vars
  deleteRegistry: ({ commit }, image) => axios.delete(image.destroyPath),

  setMainEndpoint: ({ commit }, data) => commit(types.SET_MAIN_ENDPOINT, data),
  toggleLoading: ({ commit }) => commit(types.TOGGLE_MAIN_LOADING),
};
