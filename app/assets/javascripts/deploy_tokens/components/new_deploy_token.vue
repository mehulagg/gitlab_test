<script>
import {
  GlFormGroup,
  GlFormInput,
  GlFormCheckbox,
  GlButton,
  GlDatepicker,
  GlFormInputGroup,
} from '@gitlab/ui';
import createFlash from '~/flash';
import axios from '~/lib/utils/axios_utils';
import { formatDate } from '~/lib/utils/datetime_utility';
import ClipboardButton from '~/vue_shared/components/clipboard_button.vue';
import { s__ } from '~/locale';

export default {
  components: {
    GlFormGroup,
    GlFormInput,
    GlDatepicker,
    GlFormCheckbox,
    GlButton,
    GlFormInputGroup,
    ClipboardButton,
  },

  props: {
    createNewTokenPath: {
      type: String,
      required: true,
    },
    containerRegistryEnabled: {
      type: Boolean,
      required: true,
    },
  },

  data() {
    return {
      expiresAt: null,
      name: '',
      newTokenDetails: null,
      readRepository: false,
      readRegistry: false,
      username: '',
    };
  },

  translations: {
    addTokenButton: s__('DeployTokens|Create deploy token'),
    addTokenExpiryLabel: s__('DeployTokens|Expires at'),
    addTokenHeader: s__('DeployTokens|Add a deploy token'),
    addTokenHelp: s__(
      "DeployTokens|Pick a name for the application, and we'll give you a unique deploy token",
    ),
    addTokenNameLabel: s__('DeployTokens|Name'),
    addTokenRegistryHelp: s__('DeployTokens|Allows read-only access to the registry images'),
    addTokenRepositoryHelp: s__('DeployTokens|Allows read-only access to the repository'),
    addTokenScopesLabel: s__('DeployTokens|Scopes'),
    addTokenUsernameDescription: s__(
      'DeployTokens|Default format is "gitlab+deploy-token-{n}". Enter custom username if you want to change it.',
    ),
    addTokenUsernameLabel: s__('DeployTokens|Username'),
    newTokenCopyMessage: s__('DeployTokens|Copy deploy token'),
    newTokenDescription: s__(
      "DeployTokens|Use this token as a password. Make sure you save it - you won't be able to accest it again",
    ),
    newTokenMessage: s__('DeployTokens|Your New Deploy Token'),
    newTokenUsernameCopy: s__('DeployTokens|Copy username'),
    newTokenUsernameDescription: s__('DeployTokens|Use this username as a login.'),
    readRepositoryText: s__('DeployTokens|read_repository'),
    readRegistryText: s__('DeployTokens|read_registry'),
  },

  computed: {
    formattedExpiryDate() {
      return formatDate(this.expiresAt, 'yyyy-mm-dd');
    },
  },
  methods: {
    createDeployToken() {
      return axios
        .post(this.createNewTokenPath, {
          deploy_token: {
            expires_at: this.expiresAt,
            name: this.name,
            read_repository: this.readRepository,
            read_registry: this.readRegistry,
            username: this.username,
          },
        })
        .then(response => {
          this.newTokenDetails = response.data;
        })
        .catch(error => {
          createFlash(error.message);
        });
    },
  },
};
</script>
<template>
  <div>
    <div
      v-if="newTokenDetails"
      class="qa-created-deploy-token-secton created-deploy-token-container info-well"
    >
      <div class="well-segment">
        <h5 class="prepend-top-0">{{ $options.translations.newTokenMessage }}</h5>
        <gl-form-group :description="$options.translations.newTokenUsernameDescription">
          <gl-form-input-group
            v-model="newTokenDetails.username"
            class="deploy-token-field qa-deploy-token-user"
            readonly
          >
            <template #append>
              <clipboard-button
                :text="newTokenDetails.username"
                :title="$options.translations.newTokenUsernameCopy"
              />
            </template>
          </gl-form-input-group>
        </gl-form-group>
        <gl-form-group :description="$options.translations.newTokenDescription">
          <gl-form-input-group v-model="newTokenDetails.token">
            <template #append>
              <clipboard-button
                :text="newTokenDetails.token"
                :title="$options.translations.newTokenCopyMessage"
              />
            </template>
          </gl-form-input-group>
        </gl-form-group>
      </div>
    </div>
    <h5 class="prepend-top-0">{{ $options.translations.addTokenHeader }}</h5>
    <p class="profile-settings-content">{{ $options.translations.addTokenHelp }}</p>
    <gl-form-group :label="$options.translations.addTokenNameLabel" label-for="deploy-token-name">
      <gl-form-input id="deploy-token-name" v-model="name" class="qa-deploy-token-name" />
    </gl-form-group>
    <gl-form-group
      :label="$options.translations.addTokenExpiryLabel"
      label-for="deploy-token-expires-at"
    >
      <gl-form-input
        id="deploy-token-expires-at"
        :value="formattedExpiryDate"
        class="qa-deploy-token-expires-at"
      />
    </gl-form-group>
    <gl-form-group
      :label="$options.translations.addTokenUsernameLabel"
      :description="$options.translations.addTokenUsernameDescription"
      label-for="deploy-token-username"
    >
      <gl-form-input
        id="deploy-token-username"
        v-model="username"
        class="qa-deploy-token-username"
      />
    </gl-form-group>
    <gl-form-group
      :label="$options.translations.addTokenScopesLabel"
      label-for="deploy-token-scopes"
    >
      <div id="deploy-token-scopes">
        <gl-form-checkbox id="deploy-token-read-repository" v-model="readRepository">
          {{ $options.translations.readRepositoryText }}
          <template #help>{{ $options.translations.addTokenRepositoryHelp }}</template>
        </gl-form-checkbox>
        <gl-form-checkbox
          v-if="containerRegistryEnabled"
          id="deploy-token-read-registry"
          v-model="readRegistry"
        >
          {{ $options.translations.readRegistryText }}
          <template #help>{{ $options.translations.addTokenRegistryHelp }}</template>
        </gl-form-checkbox>
      </div>
    </gl-form-group>
    <div class="prepend-top-default">
      <gl-button variant="success" class="qa-create-deploy-token" @click="createDeployToken">
        {{ $options.translations.addTokenButton }}
      </gl-button>
    </div>
    <gl-datepicker v-model="expiresAt" target="#deploy-token-expires-at" container="body" />
  </div>
</template>
