import axios from '~/lib/utils/axios_utils';
import * as types from './mutation_types';

const getAllProjects = (url, page = '1', projects = []) =>
  axios({
    method: 'GET',
    url,
    params: {
      per_page: 100,
      page,
      include_subgroups: true,
      order_by: 'path',
      sort: 'asc',
    },
  }).then(({ headers, data }) => {
    const result = projects.concat(data);
    const nextPage = headers && headers['x-next-page'];
    if (nextPage) {
      return getAllProjects(url, nextPage, result);
    }
    return result;
  });

export default {
  setProjectsEndpoint: ({ commit }, endpoint) => {
    commit(types.SET_PROJECTS_ENDPOINT, endpoint);
  },

  fetchProjects: ({ state, dispatch }) => {
    dispatch('requestProjects');

    getAllProjects(state.projectsEndpoint)
      .then(projects => {
        dispatch('receiveProjectsSuccess', { projects });
      })
      .catch(() => {
        dispatch('receiveProjectsError');
      });
  },

  requestProjects: ({ commit }) => {
    commit(types.REQUEST_PROJECTS);
  },

  receiveProjectsSuccess: ({ commit }, { projects }) => {
    commit(types.RECEIVE_PROJECTS_SUCCESS, { projects });
  },

  receiveProjectsError: ({ commit }) => {
    commit(types.RECEIVE_PROJECTS_ERROR);
  },
};
