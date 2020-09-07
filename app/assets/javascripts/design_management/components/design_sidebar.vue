<script>
import Cookies from 'js-cookie';
import { GlCollapse, GlButton, GlPopover } from '@gitlab/ui';
import { s__ } from '~/locale';
import { parseBoolean } from '~/lib/utils/common_utils';
import updateActiveDiscussionMutation from '../graphql/mutations/update_active_discussion.mutation.graphql';
import createDesignTodoMutation from '../graphql/mutations/create_design_todo.mutation.graphql';
import todoMarkDoneMutation from '~/graphql_shared/mutations/todo_mark_done.mutation.graphql';
import {
  extractDiscussions,
  extractParticipants,
  findIssueId,
  findDesignIssuableId,
} from '../utils/design_management_utils';
import { ACTIVE_DISCUSSION_SOURCE_TYPES } from '../constants';
import { CREATE_DESIGN_TODO_ERROR, DELETE_DESIGN_TODO_ERROR } from '../utils/error_messages';
import DesignDiscussion from './design_notes/design_discussion.vue';
import Participants from '~/sidebar/components/participants/participants.vue';
import TodoButton from '~/vue_shared/components/todo_button.vue';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import allVersionsMixin from '../mixins/all_versions';
import {
  updateStoreAfterCreateDesignTodo,
  updateStoreAfterDeleteDesignTodo,
} from '../utils/cache_update';
import getDesignQuery from '../graphql/queries/get_design.query.graphql';

export default {
  components: {
    DesignDiscussion,
    Participants,
    GlCollapse,
    GlButton,
    GlPopover,
    TodoButton,
  },
  mixins: [glFeatureFlagsMixin(), allVersionsMixin],
  props: {
    design: {
      type: Object,
      required: true,
    },
    resolvedDiscussionsExpanded: {
      type: Boolean,
      required: true,
    },
    markdownPreviewPath: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      isResolvedCommentsPopoverHidden: parseBoolean(Cookies.get(this.$options.cookieKey)),
      discussionWithOpenForm: '',
    };
  },
  inject: {
    projectPath: {
      default: '',
    },
    issueIid: {
      default: '',
    },
  },
  computed: {
    designVariables() {
      return {
        fullPath: this.projectPath,
        iid: this.issueIid,
        filenames: [this.$route.params.id],
        atVersion: this.designsVersion,
      };
    },
    designTodoVariables() {
      return {
        project_path: this.projectPath,
        issuable_id: parseInt(findDesignIssuableId(this.design.id), 10),
        issue_id: parseInt(findIssueId(this.design.issue.id), 10),
      };
    },
    discussions() {
      return extractDiscussions(this.design.discussions);
    },
    issue() {
      return {
        ...this.design.issue,
        webPath: this.design.issue.webPath.substr(1),
      };
    },
    discussionParticipants() {
      return extractParticipants(this.issue.participants.nodes);
    },
    resolvedDiscussions() {
      return this.discussions.filter(discussion => discussion.resolved);
    },
    unresolvedDiscussions() {
      return this.discussions.filter(discussion => !discussion.resolved);
    },
    resolvedCommentsToggleIcon() {
      return this.resolvedDiscussionsExpanded ? 'chevron-down' : 'chevron-right';
    },
    showTodoButton() {
      return this.glFeatures.designManagementTodoButton;
    },
    sidebarWrapperClass() {
      return {
        'gl-pt-0': this.showTodoButton,
      };
    },
    pendingTodo() {
      // TODO data structure pending BE MR: https://gitlab.com/gitlab-org/gitlab/-/merge_requests/40555#note_405732940
      return this.design.currentUserTodos?.nodes[0];
    },
  },
  watch: {
    isResolvedCommentsPopoverHidden(newVal) {
      if (!newVal) {
        this.$refs.resolvedComments.scrollIntoView();
      }
    },
  },
  mounted() {
    if (!this.isResolvedCommentsPopoverHidden && this.$refs.resolvedComments) {
      this.$refs.resolvedComments.$el.scrollIntoView();
    }
  },
  methods: {
    handleSidebarClick() {
      this.isResolvedCommentsPopoverHidden = true;
      Cookies.set(this.$options.cookieKey, 'true', { expires: 365 * 10 });
      this.updateActiveDiscussion();
    },
    updateActiveDiscussion(id) {
      this.$apollo.mutate({
        mutation: updateActiveDiscussionMutation,
        variables: {
          id,
          source: ACTIVE_DISCUSSION_SOURCE_TYPES.discussion,
        },
      });
    },
    closeCommentForm() {
      this.comment = '';
      this.$emit('closeCommentForm');
    },
    updateDiscussionWithOpenForm(id) {
      this.discussionWithOpenForm = id;
    },
    createTodo() {
      const { designVariables } = this;

      return this.$apollo.mutate({
        mutation: createDesignTodoMutation,
        variables: this.designTodoVariables,
        update(
          store,
          {
            data: { createDesignTodo },
          },
        ) {
          updateStoreAfterCreateDesignTodo(
            store,
            createDesignTodo,
            getDesignQuery,
            designVariables,
          );
        },
      });
    },
    emitError(message) {
      this.$emit('error', { message });
    },
    deleteTodo() {
      if (!this.pendingTodo) return Promise.reject();

      const { id } = this.pendingTodo;
      const { designVariables } = this;

      return this.$apollo.mutate({
        mutation: todoMarkDoneMutation,
        variables: {
          id,
        },
        update(
          store,
          {
            data: { createDesignTodo },
          },
        ) {
          updateStoreAfterDeleteDesignTodo(
            store,
            createDesignTodo,
            getDesignQuery,
            designVariables,
          );
        },
      });
    },
    toggleTodo() {
      if (this.pendingTodo) {
        return this.deleteTodo().catch(() => {
          this.emitError(DELETE_DESIGN_TODO_ERROR);
        });
      }

      return this.createTodo().catch(() => {
        this.emitError(CREATE_DESIGN_TODO_ERROR);
      });
    },
  },
  resolveCommentsToggleText: s__('DesignManagement|Resolved Comments'),
  cookieKey: 'hide_design_resolved_comments_popover',
};
</script>

<template>
  <div class="image-notes" :class="sidebarWrapperClass" @click="handleSidebarClick">
    <div
      v-if="showTodoButton"
      class="gl-py-4 gl-mb-4 gl-display-flex gl-justify-content-space-between gl-align-items-center gl-border-b-1 gl-border-b-solid gl-border-b-gray-100"
    >
      <span>{{ __('To-Do') }}</span>
      <todo-button
        issuable-type="design"
        :issuable-id="design.iid"
        :is-todo="pendingTodo"
        @click.prevent.stop="toggleTodo"
      />
    </div>
    <h2 class="gl-font-weight-bold gl-mt-0">
      {{ issue.title }}
    </h2>
    <a
      class="gl-text-gray-400 gl-text-decoration-none gl-mb-6 gl-display-block"
      :href="issue.webUrl"
      >{{ issue.webPath }}</a
    >
    <participants
      :participants="discussionParticipants"
      :show-participant-label="false"
      class="gl-mb-4"
    />
    <h2
      v-if="unresolvedDiscussions.length === 0"
      class="new-discussion-disclaimer gl-font-base gl-m-0 gl-mb-4"
      data-testid="new-discussion-disclaimer"
    >
      {{ s__("DesignManagement|Click the image where you'd like to start a new discussion") }}
    </h2>
    <design-discussion
      v-for="discussion in unresolvedDiscussions"
      :key="discussion.id"
      :discussion="discussion"
      :design-id="$route.params.id"
      :noteable-id="design.id"
      :markdown-preview-path="markdownPreviewPath"
      :resolved-discussions-expanded="resolvedDiscussionsExpanded"
      :discussion-with-open-form="discussionWithOpenForm"
      data-testid="unresolved-discussion"
      @createNoteError="$emit('onDesignDiscussionError', $event)"
      @updateNoteError="$emit('updateNoteError', $event)"
      @resolveDiscussionError="$emit('resolveDiscussionError', $event)"
      @click.native.stop="updateActiveDiscussion(discussion.notes[0].id)"
      @openForm="updateDiscussionWithOpenForm"
    />
    <template v-if="resolvedDiscussions.length > 0">
      <gl-button
        id="resolved-comments"
        ref="resolvedComments"
        data-testid="resolved-comments"
        :icon="resolvedCommentsToggleIcon"
        variant="link"
        class="link-inherit-color gl-text-body gl-text-decoration-none gl-font-weight-bold gl-mb-4"
        @click="$emit('toggleResolvedComments')"
        >{{ $options.resolveCommentsToggleText }} ({{ resolvedDiscussions.length }})
      </gl-button>
      <gl-popover
        v-if="!isResolvedCommentsPopoverHidden"
        :show="!isResolvedCommentsPopoverHidden"
        target="resolved-comments"
        container="popovercontainer"
        placement="top"
        :title="s__('DesignManagement|Resolved Comments')"
      >
        <p>
          {{
            s__(
              'DesignManagement|Comments you resolve can be viewed and unresolved by going to the "Resolved Comments" section below',
            )
          }}
        </p>
        <a
          href="https://docs.gitlab.com/ee/user/project/issues/design_management.html#resolve-design-threads"
          rel="noopener noreferrer"
          target="_blank"
          >{{ s__('DesignManagement|Learn more about resolving comments') }}</a
        >
      </gl-popover>
      <gl-collapse :visible="resolvedDiscussionsExpanded" class="gl-mt-3">
        <design-discussion
          v-for="discussion in resolvedDiscussions"
          :key="discussion.id"
          :discussion="discussion"
          :design-id="$route.params.id"
          :noteable-id="design.id"
          :markdown-preview-path="markdownPreviewPath"
          :resolved-discussions-expanded="resolvedDiscussionsExpanded"
          :discussion-with-open-form="discussionWithOpenForm"
          data-testid="resolved-discussion"
          @error="$emit('onDesignDiscussionError', $event)"
          @updateNoteError="$emit('updateNoteError', $event)"
          @openForm="updateDiscussionWithOpenForm"
          @click.native.stop="updateActiveDiscussion(discussion.notes[0].id)"
        />
      </gl-collapse>
    </template>
    <slot name="replyForm"></slot>
  </div>
</template>
