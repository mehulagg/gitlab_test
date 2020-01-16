<script>
import { GlAlert } from '@gitlab/ui';

export default {
  name: 'VueAlert',
  components: {
    GlAlert,
  },
  props: {
    ...GlAlert.props,

    // this prop must be explicitly added as the GlAlert's
    // "message" is a slot (and not an actual Vue prop)
    message: {
      type: String,
      required: true,
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
  <gl-alert v-if="showAlert" v-bind="$props" @dismiss="showAlert = false">
    {{ message }}
  </gl-alert>
</template>
