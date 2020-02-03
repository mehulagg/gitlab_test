import axios from '~/lib/utils/axios_utils';
import { __ } from '~/locale';
import createFlash from '~/flash';
import { refreshCurrentPage } from '~/lib/utils/url_utility';
import * as mutationTypes from './mutation_types';

export const setVaultUrl = ({ commit }, url) => commit(mutationTypes.SET_VAULT_URL, url);

export const setVaultToken = ({ commit }, token) => commit(mutationTypes.SET_VAULT_TOKEN, token);

export const setVaultEnabled = ({ commit }, enabled) =>
  commit(mutationTypes.SET_VAULT_ENABLED, enabled);

export const setVaultSslPemContents = ({ commit }, content) =>
  commit(mutationTypes.SET_VAULT_SSL_PEM_CONTENTS, content);

export const setVaultProtectedSecrets = ({ commit }, content) =>
  commit(mutationTypes.SET_VAULT_PROTECTED_SECRETS, content);

export const updateVaultIntegration = ({ state, dispatch }) =>
  axios
    .patch(state.operationsSettingsEndpoint, {
      project: {
        vault_integration_attributes: {
          vault_url: state.vaultUrl,
          token: state.vaultToken,
          enabled: state.vaultEnabled,
          ssl_pem_contents: state.vaultSslPemContents,
          protected_secrets: state.vaultProtectedSecrets,
        },
      },
    })
    .then(() => dispatch('receiveVaultIntegrationUpdateSuccess'))
    .catch(error => dispatch('receiveVaultIntegrationUpdateError', error));

export const receiveVaultIntegrationUpdateSuccess = () => {
  /**
   * The operations_controller currently handles successful requests
   * by creating a flash banner messsage to notify the user.
   */
  refreshCurrentPage();
};

export const receiveVaultIntegrationUpdateError = (_, error) => {
  const { response } = error;
  const message = response.data && response.data.message ? response.data.message : '';

  createFlash(`${__('There was an error saving your changes.')} ${message}`, 'alert');
};
