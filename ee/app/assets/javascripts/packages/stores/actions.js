/* eslint-disable no-console */
/* eslint-disable @gitlab/i18n/no-non-i18n-strings */
import Api from 'ee/api';
import createFlash from '~/flash';
import * as types from './mutation_types';
import { createEmptyPackageJson } from './utils';

const showError = () => {
  createFlash('There was an error adding this package to your project.');
};

export const setPackage = ({ commit }, data) => {
  commit(types.SET_PACKAGE, data);
};

export const setProjectId = ({ commit }, data) => {
  commit(types.SET_PROJECT_ID, data);
};

export const setSelectedProject = ({ commit }, data) => {
  commit(types.SET_SELECTED_PROJECT, data);
};

export const setLoading = ({ commit }) => {
  commit(types.SET_LOADING);
};

export const setBranchName = ({ commit, state }) => {
  const branchName = `adding-${state.package.name}-${state.package.version}-to-${state.selectedProject.default_branch}`;

  commit(types.SET_BRANCH_NAME, branchName);
};

export const addPackageToProject = ({ state, dispatch }) => {
  dispatch('setLoading');

  Api.project(state.projectId)
    .then(({ data }) => {
      dispatch('setSelectedProject', data);
      dispatch('searchForPackageJson');
    })
    .catch(showError);
};

export const searchForPackageJson = ({ state, dispatch }) => {
  Api.searchProjectBlobs(state.projectId, { search: 'package.json' })
    .then(({ data }) => {
      console.log('Response:', data);

      if (data && data.length) {
        // Possible file
      } else {
        // No package.json
        dispatch('createPackageJson');
      }
    })
    .catch(showError);
};

export const createPackageJson = ({ state, dispatch }) => {
  dispatch('setBranchName');
  const packageJsonContent = createEmptyPackageJson(state.selectedProject, state.package);

  Api.commitMultiple(state.projectId, {
    branch: state.branchName,
    commit_message: 'Adding new package',
    start_branch: state.selectedProject.default_branch,
    actions: [
      {
        action: 'create',
        file_path: 'package.json',
        content: JSON.stringify(packageJsonContent, null, 2),
      },
    ],
  })
    .then(res => {
      console.log('Commit response:', res);
      dispatch('createMergeRequest');
    })
    .catch(showError);
};

export const createMergeRequest = ({ state }) => {
  Api.projectCreateMergeRequest(state.projectId, {
    source_branch: state.branchName,
    target_branch: state.selectedProject.default_branch,
    title: `Adding ${state.package.name} ${state.package.version} to ${state.selectedProject.default_branch}`,
    description: `An automatically generated merge request to add ${state.package.name} ${state.package.version} to ${state.selectedProject.default_branch}.`,
    remove_source_branch: true,
  })
    .then(({ data }) => {
      console.log('MR:', data);
      window.location.href = data.web_url;
    })
    .catch(showError);
};

// prevent babel-plugin-rewire from generating an invalid default during karma tests
export default () => {};
