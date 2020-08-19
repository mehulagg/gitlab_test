<script>
import { GlAlert } from '@gitlab/ui';

export default {
  components: {
    GlAlert,
  },
  props: {
    html: {
      type: String,
      required: false,
      default: '',
    },
  },
  data() {
    return {
      isDismissed: false,
    };
  },
  methods: {
    dismiss() {
      this.isDismissed = true;
    },
  },
};
</script>

<template>
  <gl-alert v-if="!isDismissed" v-bind="$attrs" @dismiss="dismiss" v-on="$listeners">
    <!-- eslint-disable vue/no-v-html -->
    <div v-html="html"></div>
    <!-- eslint-enable vue/no-v-html -->
  </gl-alert>
</template>
