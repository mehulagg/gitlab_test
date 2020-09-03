<script>
import { GlButton } from '@gitlab/ui';

export default {
  components: {
    GlButton,
  },
  name: 'ReplyPlaceholder',
  props: {
    buttonText: {
      type: String,
      required: true,
    },
  },
};
</script>

<template>
  <gl-button
    ref="button"
    type="button"
    class="js-vue-discussion-reply btn-text-field"
    :title="s__('MergeRequests|Add a reply')"
    @click="$emit('onClick')"
  >
    {{ buttonText }}
  </gl-button>
</template>
