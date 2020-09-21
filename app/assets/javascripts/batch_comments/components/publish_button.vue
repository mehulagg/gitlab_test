<script>
import { mapActions, mapState, mapGetters } from 'vuex';
import {
  GlButton,
  GlNewDropdown as GlDropdown,
  GlNewDropdownItem as GlDropdownItem,
} from '@gitlab/ui';
import DraftsCount from './drafts_count.vue';

export default {
  components: {
    GlButton,
    GlDropdown,
    GlDropdownItem,
    DraftsCount,
  },
  props: {
    showCount: {
      type: Boolean,
      required: false,
      default: false,
    },
    reviewBar: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  computed: {
    ...mapState('batchComments', ['isPublishing']),
    ...mapGetters('batchComments', ['isPublishingDraft', 'draftsCount']),
  },
  methods: {
    ...mapActions('batchComments', ['publishReview']),
    publishAll() {
      this.publishReview();
    },
    publishSingleDraftHandler() {
      this.$emit('handlePublishSingleDraft');
    },
  },
};
</script>

<template>
  <gl-dropdown
    v-if="draftsCount > 1 && !reviewBar"
    :disabled="isPublishing"
    category="secondary"
    variant="success"
    split
    right
    @click="publishAll"
  >
    <template #button-content>
      {{ n__('Publish comment', 'Publish comments', draftsCount) }} 
      <drafts-count v-if="showCount" />
    </template>
    <gl-dropdown-item @click="publishSingleDraftHandler">{{ __('Publish just this comment') }}</gl-dropdown-item>
  </gl-dropdown>
  <gl-button
    v-else
    :loading="isPublishing"
    variant="success"
    class="js-publish-draft-button qa-submit-review"
    @click="publishAll"
  >
    {{ n__('Publish comment', 'Publish comments', draftsCount) }}
    <drafts-count v-if="showCount" />
  </gl-button>
</template>
