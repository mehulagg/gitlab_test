<script>
import Draggable from 'vuedraggable';
import defaultSortableConfig from '~/sortable/sortable_config';

import { mapActions } from 'vuex';
import { GlLoadingIcon } from '@gitlab/ui';
import eventHub from '~/boards/eventhub';
import BoardCard from '~/boards/components/board_card.vue';
import BoardNewIssue from '~/boards/components/board_new_issue.vue';

export default {
  components: {
    BoardCard,
    BoardNewIssue,
    GlLoadingIcon,
  },
  props: {
    list: {
      type: Object,
      required: true,
    },
    disabled: {
      type: Boolean,
      required: true,
    },
    issues: {
      type: Array,
      required: true,
    },
    groupId: {
      type: Number,
      required: false,
      default: 0,
    },
    isUnassignedIssuesLane: {
      type: Boolean,
      required: false,
      default: false,
    },
    isLoading: {
      type: Boolean,
      required: false,
      default: false,
    },
    rootPath: {
      type: String,
      required: true,
    },
    epicId: {
      type: String,
      required: false,
      default: null,
    },
  },
  data() {
    return {
      showIssueForm: false,
    };
  },
  computed: {
    treeRootWrapper() {
      return Draggable;
    },
    treeRootOptions() {
      const options = {
        ...defaultSortableConfig,
        fallbackOnBody: false,
        group: 'board-epics-swimlanes',
        tag: 'ul',
        'ghost-class': 'tree-item-drag-active',
        'data-epic-id': this.epicId,
        'data-list-id': this.list.id,
        value: this.issues,
      };

      return options;
    },
  },
  created() {
    eventHub.$on(`toggle-issue-form-${this.list.id}`, this.toggleForm);
  },
  beforeDestroy() {
    eventHub.$off(`toggle-issue-form-${this.list.id}`, this.toggleForm);
  },
  methods: {
    ...mapActions(['moveIssueEpicSwimlane']),
    toggleForm() {
      this.showIssueForm = !this.showIssueForm;
      if (this.showIssueForm && this.isUnassignedIssuesLane) {
        this.$el.scrollIntoView(false);
      }
    },
    handleDragOnEnd(params) {
      const { oldIndex, newIndex, from, to, item } = params;
      const { issueId, epicIssueId } = item.dataset;

      if (epicIssueId) {
        this.moveIssueEpicSwimlane({
          listId: to.dataset.listId,
          epicFromId: from.dataset.epicId,
          epicToId: to.dataset.epicId,
          targetIssueId: Number(issueId),
          epicIssueId,
          oldIndex,
          newIndex,
        });
      }
    },
  },
};
</script>

<template>
  <div
    class="board gl-px-3 gl-vertical-align-top gl-white-space-normal gl-display-flex gl-flex-shrink-0"
    :class="{ 'is-collapsed': !list.isExpanded }"
  >
    <div class="board-inner gl-rounded-base gl-relative gl-w-full">
      <gl-loading-icon v-if="isLoading" class="gl-p-2" />
      <board-new-issue
        v-if="list.type !== 'closed' && showIssueForm && isUnassignedIssuesLane"
        :group-id="groupId"
        :list="list"
      />
      <component
        :is="treeRootWrapper"
        v-if="list.isExpanded"
        v-bind="treeRootOptions"
        class="gl-p-2 gl-m-0"
        @end="handleDragOnEnd"
      >
        <board-card
          v-for="(issue, index) in issues"
          ref="issue"
          :key="issue.id"
          :index="index"
          :list="list"
          :issue="issue"
        />
      </component>
    </div>
  </div>
</template>
