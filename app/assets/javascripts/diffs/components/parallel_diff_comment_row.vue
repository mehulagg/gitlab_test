<script>
import { mapActions } from 'vuex';
import { LINE_POSITION_LEFT, LINE_POSITION_RIGHT } from '../constants';
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
    hasExpandedDiscussionOnLeft() {
      return this.line[LINE_POSITION_LEFT] && this.line[LINE_POSITION_LEFT].discussions.length
        ? this.line[LINE_POSITION_LEFT].discussionsExpanded
        : false;
    },
    hasExpandedDiscussionOnRight() {
      return this.line[LINE_POSITION_RIGHT] && this.line[LINE_POSITION_RIGHT].discussions.length
        ? this.line[LINE_POSITION_RIGHT].discussionsExpanded
        : false;
    },
    hasAnyExpandedDiscussion() {
      return this.hasExpandedDiscussionOnLeft || this.hasExpandedDiscussionOnRight;
    },
    shouldRenderDiscussionsOnLeft() {
      return (
        this.line[LINE_POSITION_LEFT] &&
        this.line[LINE_POSITION_LEFT].discussions &&
        this.line[LINE_POSITION_LEFT].discussions.length &&
        this.hasExpandedDiscussionOnLeft
      );
    },
    shouldRenderDiscussionsOnRight() {
      return (
        this.line[LINE_POSITION_RIGHT] &&
        this.line[LINE_POSITION_RIGHT].discussions &&
        this.line[LINE_POSITION_RIGHT].discussions.length &&
        this.hasExpandedDiscussionOnRight &&
        this.line[LINE_POSITION_RIGHT].type
      );
    },
    showRightSideCommentForm() {
      return (
        this.line[LINE_POSITION_RIGHT] &&
        this.line[LINE_POSITION_RIGHT].type &&
        this.line[LINE_POSITION_RIGHT].hasForm
      );
    },
    showLeftSideCommentForm() {
      return this.line[LINE_POSITION_LEFT] && this.line[LINE_POSITION_LEFT].hasForm;
    },
    className() {
      return (this[LINE_POSITION_LEFT] && this.line[LINE_POSITION_LEFT].discussions.length > 0) ||
        (this[LINE_POSITION_RIGHT] && this.line[LINE_POSITION_RIGHT].discussions.length > 0)
        ? ''
        : 'js-temp-notes-holder';
    },
    shouldRender() {
      const { line } = this;
      const hasDiscussion =
        (line[LINE_POSITION_LEFT] &&
          line[LINE_POSITION_LEFT].discussions &&
          line[LINE_POSITION_LEFT].discussions.length) ||
        (line[LINE_POSITION_RIGHT] &&
          line[LINE_POSITION_RIGHT].discussions &&
          line[LINE_POSITION_RIGHT].discussions.length);

      if (
        hasDiscussion &&
        (this.hasExpandedDiscussionOnLeft || this.hasExpandedDiscussionOnRight)
      ) {
        return true;
      }

      const hasCommentFormOnLeft = line[LINE_POSITION_LEFT] && line[LINE_POSITION_LEFT].hasForm;
      const hasCommentFormOnRight = line[LINE_POSITION_RIGHT] && line[LINE_POSITION_RIGHT].hasForm;

      return hasCommentFormOnLeft || hasCommentFormOnRight;
    },
    shouldRenderReplyPlaceholderOnLeft() {
      return Boolean(
        this.line[LINE_POSITION_LEFT] &&
          this.line[LINE_POSITION_LEFT].discussions &&
          this.line[LINE_POSITION_LEFT].discussions.length,
      );
    },
    shouldRenderReplyPlaceholderOnRight() {
      return Boolean(
        this.line[LINE_POSITION_RIGHT] &&
          this.line[LINE_POSITION_RIGHT].discussions &&
          this.line[LINE_POSITION_RIGHT].discussions.length,
      );
    },
  },
  methods: {
    ...mapActions('diffs', ['showCommentForm']),
    showNewDiscussionForm() {
      this.showCommentForm({ lineCode: this.line.line_code, fileHash: this.diffFileHash });
    },
  },
  LINE_POSITION_LEFT,
  LINE_POSITION_RIGHT,
};
</script>

<template>
  <tr v-if="shouldRender" :class="className" class="notes_holder">
    <td class="notes-content parallel old" colspan="3">
      <div v-if="shouldRenderDiscussionsOnLeft" class="content">
        <diff-discussions
          :discussions="line[$options.LINE_POSITION_LEFT].discussions"
          :line="line[$options.LINE_POSITION_LEFT]"
          :help-page-path="helpPagePath"
        />
      </div>
      <diff-discussion-reply
        v-if="!hasDraftLeft"
        :has-form="showLeftSideCommentForm"
        :render-reply-placeholder="shouldRenderReplyPlaceholderOnLeft"
        @showNewDiscussionForm="showNewDiscussionForm"
      >
        <template #form>
          <diff-line-note-form
            :diff-file-hash="diffFileHash"
            :line="line[$options.LINE_POSITION_LEFT]"
            :note-target-line="line[$options.LINE_POSITION_LEFT]"
            :help-page-path="helpPagePath"
            line-position="left"
          />
        </template>
      </diff-discussion-reply>
    </td>
    <td class="notes-content parallel new" colspan="3">
      <div v-if="shouldRenderDiscussionsOnRight" class="content">
        <diff-discussions
          :discussions="line[$options.LINE_POSITION_RIGHT].discussions"
          :line="line[$options.LINE_POSITION_RIGHT]"
          :help-page-path="helpPagePath"
        />
      </div>
      <diff-discussion-reply
        v-if="!hasDraftRight"
        :has-form="showRightSideCommentForm"
        :render-reply-placeholder="shouldRenderReplyPlaceholderOnRight"
        @showNewDiscussionForm="showNewDiscussionForm"
      >
        <template #form>
          <diff-line-note-form
            :diff-file-hash="diffFileHash"
            :line="line[$options.LINE_POSITION_RIGHT]"
            :note-target-line="line[$options.LINE_POSITION_RIGHT]"
            line-position="right"
          />
        </template>
      </diff-discussion-reply>
    </td>
  </tr>
</template>
