<script>
import { GlAlert } from '@gitlab/ui';

export default {
  name: 'VueAlert',
  components: {
    GlAlert,
  },
  props: {
    message: {
      type: String,
      required: true,
    },
    variant: {
      type: String,
      required: false,
      default: 'danger',
    },
    title: {
      type: String,
      required: false,
      default: '',
    },
    dismissible: {
      type: Boolean,
      required: false,
      default: true,
    },
    primaryButtonLink: {
      type: String,
      required: false,
      default: '',
    },
    primaryButtonText: {
      type: String,
      required: false,
      default: '',
    },
    secondaryButtonLink: {
      type: String,
      required: false,
      default: '',
    },
    secondaryButtonText: {
      type: String,
      required: false,
      default: '',
    },
  },
  data() {
    return {
      showAlert: true,
    };
  },
};
</script>

<template>
  <gl-alert
    v-if="showAlert"
    :title="title"
    :variant="variant"
    :dismissible="dismissible"
    :primary-button-link="primaryButtonLink"
    :primary-button-text="primaryButtonText"
    :secondary-button-link="secondaryButtonLink"
    :secondary-button-text="secondaryButtonText"
    @dismiss="showAlert = false"
    >{{ message }}</gl-alert
  >
</template>
