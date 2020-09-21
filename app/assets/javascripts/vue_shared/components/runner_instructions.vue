<script>
/* eslint-disable @gitlab/require-i18n-strings, @gitlab/vue-require-i18n-strings */
import {
  GlButton,
  GlModal,
  GlModalDirective,
  GlButtonGroup,
  GlDropdown,
  GlDropdownItem,
  GlIcon,
} from '@gitlab/ui';
import { __, s__ } from '~/locale';

export default {
  components: {
    GlButton,
    GlButtonGroup,
    GlDropdown,
    GlDropdownItem,
    GlModal,
    GlIcon,
  },
  directives: {
    GlModalDirective,
  },
  inject: {
    instructionsPath: {
      type: String,
      default: '',
    },
  },
  data() {
    return {
      selected: 'Docker', // TODO: Change this
    };
  },
  computed: {
    closeButton() {
      return {
        text: __('Close'),
        attributes: [{ variant: 'default' }],
      };
    },
  },
  methods: {
    architectureOptionClicked(option) {
      this.selected = option;
    },
  },
  modalId: 'installation-instructions-modal',
  i18n: {
    installARunner: __('Install a Runner'),
    architecture: __('Architecture'),
    downloadInstallBinary: s__('Runners|Download and Install Binnary'),
    downloadLatestBinary: s__('Runners|Download Latest Binary'),
    registerRunner: s__('Runners|Register Runner'),
    method: __('Method'),
  },
};
</script>
<template>
  <div>
    <gl-button v-gl-modal-directive="$options.modalId">
      {{ __('Show Runner installation instructions') }}
    </gl-button>
    <gl-modal
      :modal-id="$options.modalId"
      :title="$options.i18n.installARunner"
      :action-secondary="closeButton"
    >
      <h5>{{ __('Environment') }}</h5>
      <gl-button-group class="gl-mb-5">
        <gl-button>
          GNU / Linux
        </gl-button>
      </gl-button-group>
      <h5>
        {{ $options.i18n.architecture }}
      </h5>
      <gl-dropdown class="gl-mb-5" :text="selected">
        <gl-dropdown-item @click="architectureOptionClicked('Linux')">
          Linux x86-64
        </gl-dropdown-item>
      </gl-dropdown>
      <div class="gl-display-flex gl-align-items-center gl-mb-5">
        <h5>{{ $options.i18n.downloadInstallBinary }}</h5>
        <gl-button class="gl-ml-auto">
          {{ $options.i18n.downloadLatestBinary }}
        </gl-button>
      </div>
      <div class="gl-display-flex">
        <pre class="bg-light gl-flex-fill-1">
          Installation instructions...
        </pre>
        <gl-icon name="copy-to-clipboard" class="gl-ml-2 gl-mt-2" />
      </div>

      <hr />
      <h5 class="gl-mb-5">{{ $options.i18n.registerRunner }}</h5>
      <h5 class="gl-mb-5">{{ $options.i18n.method }}</h5>
      <div class="gl-display-flex">
        <pre class="bg-light gl-flex-fill-1">
          Installation instructions...
        </pre>
        <gl-icon name="copy-to-clipboard" class="gl-ml-2 gl-mt-2" />
      </div>
    </gl-modal>
  </div>
</template>
