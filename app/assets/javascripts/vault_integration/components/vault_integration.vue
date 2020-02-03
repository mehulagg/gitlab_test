<script>
import { GlButton, GlFormGroup, GlFormInput, GlFormCheckbox, GlFormTextarea } from '@gitlab/ui';
import { mapState, mapActions } from 'vuex';

export default {
  components: {
    GlButton,
    GlFormCheckbox,
    GlFormGroup,
    GlFormInput,
    GlFormTextarea,
  },
  data() {
    return { placeholderUrl: 'https://my-url.vault.net/' };
  },
  computed: {
    ...mapState([
      'operationsSettingsEndpoint',
      'vaultToken',
      'vaultUrl',
      'vaultEnabled',
      'vaultSslPemContents',
      'vaultProtectedSecrets',
    ]),
    integrationEnabled: {
      get() {
        return this.vaultEnabled;
      },
      set(vaultEnabled) {
        this.setVaultEnabled(vaultEnabled);
      },
    },
    localVaultToken: {
      get() {
        return this.vaultToken;
      },
      set(token) {
        this.setVaultToken(token);
      },
    },
    localVaultUrl: {
      get() {
        return this.vaultUrl;
      },
      set(url) {
        this.setVaultUrl(url);
      },
    },
    localVaultSslPemContents: {
      get() {
        return this.vaultSslPemContents;
      },
      set(content) {
        this.setVaultSslPemContents(content);
      },
    },
    localVaultProtectedSecrets: {
      get() {
        return this.vaultProtectedSecrets;
      },
      set(content) {
        this.setVaultProtectedSecrets(content);
      },
    },
  },
  methods: {
    ...mapActions([
      'setVaultUrl',
      'setVaultToken',
      'setVaultEnabled',
      'updateVaultIntegration',
      'setVaultSslPemContents',
      'setVaultProtectedSecrets',
    ]),
  },
};
</script>

<template>
  <section id="vault" class="settings no-animate js-vault-integration">
    <div class="settings-header">
      <h4 class="js-section-header">
        {{ s__('VaultIntegration|Vault Integration') }}
      </h4>
      <gl-button class="js-settings-toggle">{{ __('Expand') }}</gl-button>
      <p class="js-section-sub-header">
        {{ s__('VaultIntegration|Send Vault secrets to CI jobs.') }}
      </p>
    </div>
    <div class="settings-content">
      <form>
        <gl-form-checkbox id="vault-integration-enabled" v-model="integrationEnabled" class="mb-4">
          {{ s__('VaultIntegration|Active') }}
        </gl-form-checkbox>
        <gl-form-group
          :label="s__('VaultIntegration|Vault URL')"
          label-for="vault-url"
          :description="s__('VaultIntegration|Enter the base URL of the Vault instance.')"
        >
          <gl-form-input id="vault-url" v-model="localVaultUrl" :placeholder="placeholderUrl" />
        </gl-form-group>
        <gl-form-group :label="s__('VaultIntegration|API Token')" label-for="vault-token">
          <gl-form-input id="vault-token" v-model="localVaultToken" type="password" />
        </gl-form-group>

        <div>
          <p class="form-text text-muted">
            {{ s__('VaultIntegration|Or') }}
          </p>
        </div>

        <gl-form-group
          :label="s__('VaultIntegration|SSL certificate and key')"
          label-for="vault-ssl-pem-contents"
        >
          <gl-form-textarea id="vault-ssl-pem-contents" v-model="localVaultSslPemContents" />
        </gl-form-group>

        <gl-form-group
          :label="s__('VaultIntegration|Protected secrets')"
          label-for="vault-protected_secrets"
        >
          <gl-form-textarea id="vault-protected-secrets" v-model="localVaultProtectedSecrets" />
        </gl-form-group>

        <gl-button variant="success" @click="updateVaultIntegration">
          {{ __('Save Changes') }}
        </gl-button>
      </form>
    </div>
  </section>
</template>
