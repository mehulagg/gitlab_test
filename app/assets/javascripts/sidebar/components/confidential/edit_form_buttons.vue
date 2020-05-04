<script>
import { GlLoadingIcon } from '@gitlab/ui';
import eventHub from '../../event_hub';
import { __ } from '~/locale';

export default {
  components: {
    GlLoadingIcon,
  },
  props: {
    isConfidential: {
      required: true,
      type: Boolean,
    },
    updateConfidentialAttribute: {
      required: true,
      type: Function,
    },
    loading: {
      required: true,
      type: Boolean,
    }
  },
  computed: {
    toggleButtonText() {
      return this.isConfidential ? __('Turn Off') : __('Turn On');
    },
    updateConfidentialBool() {
      return !this.isConfidential;
    },
  },
  methods: {
    closeForm() {
      eventHub.$emit('closeConfidentialityForm');
    },
    submitForm() {
      this.updateConfidentialAttribute(this.updateConfidentialBool);
    },
  },
};
</script>

<template>
  <div class="sidebar-item-warning-message-actions">
    <button type="button" class="btn btn-default append-right-10" @click="closeForm">
      {{ __('Cancel') }}
    </button>
    <button type="button" class="btn btn-close" :disabled="loading" @click.prevent="submitForm">
      <gl-loading-icon v-if="loading" :inline="true" />
      {{ toggleButtonText }}
    </button>
  </div>
</template>
