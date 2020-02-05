<script>
import { mapActions } from 'vuex';
import { GlLoadingIcon, GlAlert } from '@gitlab/ui';

export default {
  components: {
    GlLoadingIcon,
    GlAlert,
  },
  props: {
    message: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      isLoading: false,
      canDismiss:
        this.message.hasOwnProperty('action') === false ||
        typeof this.message.action === 'undefined',
    };
  },
  methods: {
    ...mapActions(['setErrorMessage']),
    clickAction() {
      if (this.isLoading) return;

      this.isLoading = true;

      this.message
        .action(this.message.actionPayload)
        .then(() => {
          this.isLoading = false;
        })
        .catch(() => {
          this.isLoading = false;
        });
    },
    clickDismiss() {
      this.setErrorMessage(null);
    },
  },
};
</script>

<template>
  <gl-alert
    variant="danger"
    :primary-button-text="message.actionText"
    :dismissible="canDismiss"
    @primaryAction="clickAction"
    @dismiss="clickDismiss"
  >
    <span v-html="message.text" />
    <gl-loading-icon v-show="isLoading" inline />
  </gl-alert>
</template>
