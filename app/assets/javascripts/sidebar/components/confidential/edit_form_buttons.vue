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
    loading: {
      required: true,
      type: Boolean,
    },
  },
  computed: {
    toggleButtonText() {
      return this.isConfidential ? __('Turn Off') : __('Turn On');
    },
  },
  methods: {
    closeForm() {
      eventHub.$emit('closeConfidentialityForm');
    },
    submitForm() {
      eventHub.$emit('updateConfidentialAttribute');
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
