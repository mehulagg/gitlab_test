<script>
import { mapActions } from 'vuex';
import DiffDiscussions from './diff_discussions.vue';
import DiffLineNoteForm from './diff_line_note_form.vue';
import DiffDiscussionReply from './diff_discussion_reply.vue';

export default {
  components: {
    DiffDiscussions,
    DiffLineNoteForm,
    DiffDiscussionReply,
  },
  props: {
    line: {
      type: Object,
      required: true,
    },
    diffFileHash: {
      type: String,
      required: true,
    },
    lineIndex: {
      type: Number,
      required: true,
    },
    helpPagePath: {
      type: String,
      required: false,
      default: '',
    },
    hasDraftLeft: {
      type: Boolean,
      required: false,
      default: false,
    },
    hasDraftRight: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  computed: {
    left() {
      return this.line.left || { discussions: [] };
    },
    right() {
      return this.line.right || { discussions: [] };
    },
    hasExpandedDiscussionOnLeft() {
      return this.left.discussions.length && this.left.discussionsExpanded;
    },
    hasExpandedDiscussionOnRight() {
      return this.right.discussions.length && this.right.discussionsExpanded;
    },
    className() {
      return this.left.discussions.length || this.right.discussions.length
        ? ''
        : 'js-temp-notes-holder';
    },
  },
  methods: {
    ...mapActions('diffs', ['showCommentForm']),
    showNewDiscussionForm() {
      this.showCommentForm({ lineCode: this.line.line_code, fileHash: this.diffFileHash });
    },
  },
};
</script>

<template>
  <tr :class="className" class="notes_holder">
    <td class="notes-content parallel old" colspan="3">
      <div v-if="hasExpandedDiscussionOnLeft" class="content">
        <diff-discussions
          :discussions="left.discussions"
          :line="left"
          :help-page-path="helpPagePath"
        />
      </div>
      <diff-discussion-reply
        v-if="!hasDraftLeft"
        :has-form="left.hasForm"
        :render-reply-placeholder="left.discussions.length > 0"
        @showNewDiscussionForm="showNewDiscussionForm"
      >
        <template #form>
          <diff-line-note-form
            :diff-file-hash="diffFileHash"
            :line="left"
            :note-target-line="left"
            :help-page-path="helpPagePath"
            line-position="left"
          />
        </template>
      </diff-discussion-reply>
    </td>
    <td class="notes-content parallel new" colspan="3">
      <div v-if="hasExpandedDiscussionOnRight" class="content">
        <diff-discussions
          :discussions="right.discussions"
          :line="right"
          :help-page-path="helpPagePath"
        />
      </div>
      <diff-discussion-reply
        v-if="!hasDraftRight"
        :has-form="right.hasForm"
        :render-reply-placeholder="right.discussions.length > 0"
        @showNewDiscussionForm="showNewDiscussionForm"
      >
        <template #form>
          <diff-line-note-form
            :diff-file-hash="diffFileHash"
            :line="right"
            :note-target-line="right"
            line-position="right"
          />
        </template>
      </diff-discussion-reply>
    </td>
  </tr>
</template>
