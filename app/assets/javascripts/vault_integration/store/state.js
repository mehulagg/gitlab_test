import { parseBoolean } from '~/lib/utils/common_utils';

export default (initialState = {}) => ({
  operationsSettingsEndpoint: initialState.operationsSettingsEndpoint,
  vaultToken: initialState.vaultIntegrationToken || '',
  vaultUrl: initialState.vaultIntegrationUrl || '',
  vaultSslPemContents: initialState.vaultIntegrationSslPemContents || '',
  vaultProtectedSecrets: initialState.vaultIntegrationProtectedSecrets || '',
  vaultEnabled: parseBoolean(initialState.vaultIntegrationEnabled) || false,
});
