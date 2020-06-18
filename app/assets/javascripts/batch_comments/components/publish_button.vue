<script>
import { mapActions, mapState } from 'vuex';
import { GlButton } from '@gitlab/ui';
import DraftsCount from './drafts_count.vue';

export default {
  components: {
    GlButton,
    DraftsCount,
  },
  props: {
    showCount: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  computed: {
    ...mapState('batchComments', ['isPublishing']),
  },
  methods: {
    ...mapActions('batchComments', ['publishReview']),
    onClick() {
      this.publishReview();
    },
  },
};
</script>

<template>
  <gl-button
    :loading="isPublishing"
    variant="success"
    class="js-publish-draft-button qa-submit-review"
    @click="onClick"
  >
    {{ __('Submit review') }}
    <drafts-count v-if="showCount" />
  </gl-button>
</template>
