<script>
import { GlButton, GlTooltipDirective, GlIcon } from '@gitlab/ui';
import discussionNavigation from '../mixins/discussion_navigation';

export default {
  name: 'JumpToNextDiscussionButton',
  components: {
    GlButton,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  mixins: [discussionNavigation],
  props: {
    fromDiscussionId: {
      type: String,
      required: true,
    },
  },
};
</script>

<template>
  <div class="btn-group" role="group">
    <gl-button
      v-gl-tooltip
      class="discussion-next-btn"
      icon="comment-next"
      :title="s__('MergeRequests|Jump to next unresolved thread')"
      data-track-event="click_button"
      data-track-label="mr_next_unresolved_thread"
      data-track-property="click_next_unresolved_thread"
      @click="jumpToNextRelativeDiscussion(fromDiscussionId)"
    />
  </div>
</template>
