<script>
import { GlButton, GlFormGroup, GlFormInput, GlModal, GlModalDirective } from '@gitlab/ui';
import ClipboardButton from '~/vue_shared/components/clipboard_button.vue';
import axios from '~/lib/utils/axios_utils';
import { __, sprintf } from '~/locale';
import createFlash from '~/flash';

export default {
  copyToClipboard: __('Copy to clipboard'),
  components: {
    GlButton,
    GlFormGroup,
    GlFormInput,
    GlModal,
    ClipboardButton,
  },
  directives: {
    'gl-modal': GlModalDirective,
  },
  props: {
    changeKeyUrl: {
      type: String,
      required: true,
    },
  },
  methods: {
    resetKey() {
      axios
        .post(this.changeKeyUrl)
        .then(res => {
          this.authorizationKey = res.data.token;
        })
        .catch(() => {
          createFlash(__('Failed to reset key. Please try again.'));
        });
    },
  },
};
</script>

<template>
  <div class="mt-2">
    <gl-modal
      modal-id="authKeyModal"
      :title="__('Reset key?')"
      :ok-title="__('Reset key')"
      ok-variant="danger"
      @ok="resetKey"
    >
      {{
        __(
          'Resetting the authorization key will invalidate the previous key. Existing alert configurations will need to be updated with the new key.',
        )
      }}
    </gl-modal>
    <gl-button v-gl-modal.authKeyModal class="js-reset-auth-key">{{
      __('Reset key')
    }}</gl-button>
  </div>
</template>
