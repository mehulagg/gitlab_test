<script>
import { s__ } from '~/locale';
import { GlButton, GlLoadingIcon } from '@gitlab/ui';
import createFlash, { hideFlash } from '~/flash';
import { APPROVE_ERROR, APPROVAL_PASSWORD_INVALID } from '../messages';
import eventHub from '~/vue_merge_request_widget/event_hub';

export default {
  components: {
    GlButton,
    GlLoadingIcon,
  },
  props: {
    approvalText: {
      type: String,
      required: true,
    },
    service: {
      type: Object,
      required: true,
    },
    mr: {
      type: Object,
      required: true,
    },
    refreshRules: {
      type: Function,
      required: true,
    },
  },
  data() {
    return {
      approvalPassword: null,
      isApproving: false,
      showApprovePasswordPrompt: false,
    };
  },
  computed: {
    confirmButtonText() {
      return s__('mrWidget|Confirm');
    },
    cancelButtonText() {
      return s__('mrWidget|Cancel');
    },
    approvalPasswordPlaceholder() {
      return s__('Password');
    },
  },
  methods: {
    clearError() {
      const flashEl = document.querySelector('.flash-alert');
      if (flashEl != null) {
        hideFlash(flashEl);
      }
    },
    approve() {
      this.isApproving = true;
      this.clearError();
      return this.service
        .approveMergeRequestWithAuth(this.approvalPassword)
        .then(data => {
          this.mr.setApprovals(data);
          eventHub.$emit('MRWidgetUpdateRequested');
          this.isApproving = false;
        })
        .catch(error => {
          if (error && error.response && error.response.status === 401) {
            createFlash(APPROVAL_PASSWORD_INVALID);
          } else {
            createFlash(APPROVE_ERROR);
          }
          this.isApproving = false;
        })
        .then(() => this.refreshRules());
    },
    cancel() {
      this.clearError();
      this.showApprovePasswordPrompt = false;
    },
    showPasswordPrompt() {
      this.showApprovePasswordPrompt = true;
      this.$nextTick(() => this.$refs.approvalPassword.focus());
    },
  },
};
</script>

<template>
  <div>
    <gl-button
      v-if="!showApprovePasswordPrompt"
      :variant="'primary'"
      size="sm"
      class="mr-3"
      @click="showPasswordPrompt"
    >
      <gl-loading-icon v-if="isApproving" inline />
      {{ approvalText }}
    </gl-button>
    <form
      v-if="showApprovePasswordPrompt"
      class="form-inline force-approval-auth form-row align-items-center"
      @submit.prevent="approve"
    >
      <div class="col-auto">
        <input
          id="force-auth-password"
          v-model="approvalPassword"
          ref="approvalPassword"
          type="password"
          class="form-control"
          autocomplete="new-password"
          :placeholder="approvalPasswordPlaceholder"
        />
      </div>
      <div class="col-auto">
        <gl-button :variant="'primary'" :disabled="isApproving" size="sm" @click="approve">
          <gl-loading-icon v-if="isApproving" inline />
          {{ confirmButtonText }}
        </gl-button>
        <gl-button
          :variant="'default'"
          :disabled="isApproving"
          size="sm"
          class="mr-3"
          @click="cancel"
        >
          {{ cancelButtonText }}
        </gl-button>
      </div>
    </form>
  </div>
</template>
