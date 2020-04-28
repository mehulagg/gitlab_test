<script>
import ReplyPlaceholder from '~/notes/components/discussion_reply_placeholder.vue';
import allVersionsMixin from '../../mixins/all_versions';
import DesignNote from './design_note.vue';
import DesignReplyForm from './design_reply_form.vue';
import { sendCreateNoteMutation } from './test_service';

export default {
  components: {
    DesignNote,
    ReplyPlaceholder,
    DesignReplyForm,
  },
  mixins: [allVersionsMixin],
  props: {
    discussion: {
      type: Object,
      required: true,
    },
    noteableId: {
      type: String,
      required: true,
    },
    designId: {
      type: String,
      required: true,
    },
    discussionIndex: {
      type: Number,
      required: true,
    },
    markdownPreviewPath: {
      type: String,
      required: false,
      default: '',
    },
  },
  data() {
    return {
      discussionComment: '',
      isFormRendered: false,
      loading: false,
    };
  },
  computed: {
    mutationPayload() {
      return {
        noteableId: this.noteableId,
        body: this.discussionComment,
        discussionId: this.discussion.id,
      };
    },
    designVariables() {
      return {
        fullPath: this.projectPath,
        iid: this.issueIid,
        filenames: [this.$route.params.id],
        atVersion: this.designsVersion,
      };
    },
  },
  methods: {
    createNote() {
      this.loading = true;
      sendCreateNoteMutation(this.mutationPayload, this.designVariables, this.discussion.id)
        .then(() => {
          this.discussionComment = '';
          this.hideForm();
        })
        .catch(err => this.$emit('error', err))
        .finally(() => {
          this.loading = false;
        });
    },
    hideForm() {
      this.isFormRendered = false;
      this.discussionComment = '';
    },
    showForm() {
      this.isFormRendered = true;
    },
  },
};
</script>

<template>
  <div class="design-discussion-wrapper">
    <div class="badge badge-pill" type="button">{{ discussionIndex }}</div>
    <div
      class="design-discussion bordered-box position-relative"
      data-qa-selector="design_discussion_content"
    >
      <design-note v-for="note in discussion.notes" :key="note.id" :note="note" />
      <div class="reply-wrapper">
        <reply-placeholder
          v-if="!isFormRendered"
          class="qa-discussion-reply"
          :button-text="__('Reply...')"
          @onClick="showForm"
        />
        <design-reply-form
          v-else
          v-model="discussionComment"
          :is-saving="loading"
          :markdown-preview-path="markdownPreviewPath"
          @submitForm="createNote"
          @cancelForm="hideForm"
        />
      </div>
    </div>
  </div>
</template>
