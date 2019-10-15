<script>
import _ from 'underscore';
import { truncateSha } from '~/lib/utils/text_utility';
import { s__, __, sprintf } from '~/locale';
import { mapActions } from 'vuex';
import userAvatarLink from '../../vue_shared/components/user_avatar/user_avatar_link.vue';
import noteHeader from './note_header.vue';
import noteEditedText from './note_edited_text.vue';

export default {
  name: 'DiffDiscussionHeader',
  components: {
    userAvatarLink,
    noteHeader,
    noteEditedText,
  },
  props: {
    discussion: {
      type: Object,
      required: true,
    },
  },
  computed: {
    author() {
      return this.firstNote.author;
    },
    firstNote() {
      return this.discussion.notes.slice(0, 1)[0];
    },
    lastUpdatedBy() {
      const { notes } = this.discussion;

      if (notes.length > 1) {
        return notes[notes.length - 1].author;
      }

      return null;
    },
    lastUpdatedAt() {
      const { notes } = this.discussion;

      if (notes.length > 1) {
        return notes[notes.length - 1].created_at;
      }

      return null;
    },
    resolvedText() {
      return this.discussion.resolved_by_push ? __('Automatically resolved') : __('Resolved');
    },
    actionText() {
      const linkStart = `<a href="${_.escape(this.discussion.discussion_path)}">`;
      const linkEnd = '</a>';

      let { commit_id: commitId } = this.discussion;
      if (commitId) {
        commitId = `<span class="commit-sha">${truncateSha(commitId)}</span>`;
      }

      const {
        for_commit: isForCommit,
        diff_discussion: isDiffDiscussion,
        active: isActive,
      } = this.discussion;

      let text = s__('MergeRequests|started a thread');
      if (isForCommit) {
        text = s__('MergeRequests|started a thread on commit %{linkStart}%{commitId}%{linkEnd}');
      } else if (isDiffDiscussion && commitId) {
        text = isActive
          ? s__('MergeRequests|started a thread on commit %{linkStart}%{commitId}%{linkEnd}')
          : s__(
              'MergeRequests|started a thread on an outdated change in commit %{linkStart}%{commitId}%{linkEnd}',
            );
      } else if (isDiffDiscussion) {
        text = isActive
          ? s__('MergeRequests|started a thread on %{linkStart}the diff%{linkEnd}')
          : s__(
              'MergeRequests|started a thread on %{linkStart}an old version of the diff%{linkEnd}',
            );
      }

      return sprintf(text, { commitId, linkStart, linkEnd }, false);
    },
  },
  methods: {
    ...mapActions(['toggleDiscussion']),
    toggleDiscussionHandler() {
      this.toggleDiscussion({ discussionId: this.discussion.id });
    },
  },
};
</script>

<template>
  <div class="discussion-header note-wrapper">
    <div v-once class="timeline-icon align-self-start flex-shrink-0">
      <user-avatar-link
        v-if="author"
        :link-href="author.path"
        :img-src="author.avatar_url"
        :img-alt="author.name"
        :img-size="40"
      />
    </div>
    <div class="timeline-content w-100">
      <note-header
        :author="author"
        :created-at="firstNote.created_at"
        :note-id="firstNote.id"
        :include-toggle="true"
        :expanded="discussion.expanded"
        @toggleHandler="toggleDiscussionHandler"
      >
        <span v-html="actionText"></span>
      </note-header>
      <note-edited-text
        v-if="discussion.resolved"
        :edited-at="discussion.resolved_at"
        :edited-by="discussion.resolved_by"
        :action-text="resolvedText"
        class-name="discussion-headline-light js-discussion-headline"
      />
      <note-edited-text
        v-else-if="lastUpdatedAt"
        :edited-at="lastUpdatedAt"
        :edited-by="lastUpdatedBy"
        action-text="Last updated"
        class-name="discussion-headline-light js-discussion-headline"
      />
    </div>
  </div>
</template>
