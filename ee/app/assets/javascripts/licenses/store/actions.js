import axios from '~/lib/utils/axios_utils';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';
import * as types from './mutation_types';
import flashMessage from './flash_message';

export default {
  setInitialData: ({ commit }, data) => commit(types.SET_INITIAL_DATA, data),

  requestLicenses: ({ commit }) => commit(types.REQUEST_LICENSES),
  receiveLicensesSuccess: ({ commit }, licenses) =>
    commit(types.RECEIVE_LICENSES_SUCCESS, licenses),
  receiveLicensesError: ({ commit }) => commit(types.RECEIVE_LICENSES_ERROR),
  fetchLicenses: ({ state, dispatch }) => {
    dispatch('requestLicenses');

    return axios
      .get(state.licensesPath)
      .then(({ data }) =>
        dispatch('receiveLicensesSuccess', convertObjectPropsToCamelCase(data, { deep: true })),
      )
      .catch(({ response }) => {
        flashMessage('fetchLicenses', response.status);

        dispatch('receiveLicensesError');
      });
  },

  requestDeleteLicense: ({ commit }, license) => commit(types.REQUEST_DELETE_LICENSE, license),
  receiveDeleteLicenseSuccess: ({ commit }, license) =>
    commit(types.RECEIVE_DELETE_LICENSE_SUCCESS, license),
  receiveDeleteLicenseError: ({ commit }, license) =>
    commit(types.RECEIVE_DELETE_LICENSE_ERROR, license),
  fetchDeleteLicense: ({ state, dispatch }, { id }) => {
    dispatch('requestDeleteLicense', { id });

    return axios
      .delete(state.deleteLicensePath.replace(':id', id))
      .then(() => dispatch('receiveDeleteLicenseSuccess', { id }))
      .catch(({ response }) => {
        flashMessage('fetchDeleteLicense', response.status);

        dispatch('receiveDeleteLicenseError', { id });
      });
  },
};
