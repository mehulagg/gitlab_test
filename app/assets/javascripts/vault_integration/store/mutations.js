import * as types from './mutation_types';

export default {
  [types.SET_VAULT_URL](state, url) {
    state.vaultUrl = url;
  },
  [types.SET_VAULT_TOKEN](state, token) {
    state.vaultToken = token;
  },
  [types.SET_VAULT_ENABLED](state, enabled) {
    state.vaultEnabled = enabled;
  },
  [types.SET_VAULT_SSL_PEM_CONTENTS](state, content) {
    state.vaultSslPemContents = content;
  },
  [types.SET_VAULT_PROTECTED_SECRETS](state, content) {
    state.vaultProtectedSecrets = content;
  },
};
