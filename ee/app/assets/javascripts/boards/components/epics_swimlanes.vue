<script>
import { mapActions, mapGetters, mapState } from 'vuex';
import { GlIcon, GlTooltipDirective } from '@gitlab/ui';
import Draggable from 'vuedraggable';
import BoardListHeader from 'ee_else_ce/boards/components/board_list_header.vue';
import { DRAGGABLE_TAG } from '../constants';
import defaultSortableConfig from '~/sortable/sortable_config';
import { n__ } from '~/locale';
import EpicLane from './epic_lane.vue';
import IssuesLaneList from './issues_lane_list.vue';

export default {
  components: {
    BoardListHeader,
    EpicLane,
    IssuesLaneList,
    GlIcon,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    lists: {
      type: Array,
      required: true,
    },
    disabled: {
      type: Boolean,
      required: true,
    },
    canAdminList: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  computed: {
    ...mapState(['epics']),
    ...mapGetters(['getUnassignedIssues']),
    unassignedIssues() {
      return listId => this.getUnassignedIssues(listId);
    },
    unassignedIssuesCount() {
      return this.lists.reduce(
        (total, list) => total + this.getUnassignedIssues(list.id).length,
        0,
      );
    },
    unassignedIssuesCountTooltipText() {
      return n__(`%d unassigned issue`, `%d unassigned issues`, this.unassignedIssuesCount);
    },
    treeRootWrapper() {
      return this.canAdminList ? Draggable : DRAGGABLE_TAG;
    },
    treeRootOptions() {
      const options = {
        ...defaultSortableConfig,
        fallbackOnBody: false,
        group: 'board-swimlanes',
        tag: DRAGGABLE_TAG,
        draggable: '.is-draggable',
        'ghost-class': 'swimlane-header-drag-active',
        value: this.lists,
      };

      return this.canAdminList ? options : {};
    },
  },
  methods: {
    ...mapActions(['moveList']),
    handleDragOnEnd(params) {
      const { newIndex, oldIndex, item } = params;
      const { listId } = item.dataset;

      this.moveList({
        listId,
        newIndex,
        adjustmentValue: newIndex < oldIndex ? 1 : -1,
      });
    },
  },
};
</script>

<template>
  <div
    class="board-swimlanes gl-white-space-nowrap gl-pb-5 gl-px-3"
    data_qa_selector="board_epics_swimlanes"
  >
    <component
      :is="treeRootWrapper"
      v-bind="treeRootOptions"
      class="board-swimlanes-headers gl-display-table gl-sticky gl-pt-5 gl-bg-white gl-top-0 gl-z-index-3"
      data-testid="board-swimlanes-headers"
      @end="handleDragOnEnd"
    >
      <div
        v-for="list in lists"
        :key="list.id"
        :class="{
          'is-collapsed': !list.isExpanded,
          'is-draggable': !list.preset,
        }"
        class="board gl-px-3 gl-vertical-align-top gl-white-space-normal"
        :data-list-id="list.id"
        data-testid="board-header-container"
      >
        <board-list-header
          :can-admin-list="canAdminList"
          :list="list"
          :disabled="disabled"
          :is-swimlanes-header="true"
        />
      </div>
    </component>
    <div class="board-epics-swimlanes gl-display-table">
      <epic-lane
        v-for="epic in epics"
        :key="epic.id"
        :epic="epic"
        :lists="lists"
        :disabled="disabled"
        :can-admin-list="canAdminList"
      />
      <div class="board-lane-unassigned-issues-title gl-sticky gl-display-inline-block gl-left-0">
        <div class="gl-left-0 gl-py-5 gl-px-3 gl-display-flex gl-align-items-center">
          <span
            class="gl-mr-3 gl-font-weight-bold gl-white-space-nowrap gl-text-overflow-ellipsis gl-overflow-hidden"
          >
            {{ __('Issues with no epic assigned') }}
          </span>
          <span
            v-gl-tooltip.hover
            :title="unassignedIssuesCountTooltipText"
            class="gl-display-flex gl-align-items-center gl-text-gray-500"
            tabindex="0"
            :aria-label="unassignedIssuesCountTooltipText"
            data-testid="issues-lane-issue-count"
          >
            <gl-icon class="gl-mr-2 gl-flex-shrink-0" name="issues" aria-hidden="true" />
            <span aria-hidden="true">{{ unassignedIssuesCount }}</span>
          </span>
        </div>
      </div>
      <div class="gl-display-flex" data-testid="board-lane-unassigned-issues">
        <issues-lane-list
          v-for="list in lists"
          :key="`${list.id}-issues`"
          :list="list"
          :issues="unassignedIssues(list.id)"
          :is-unassigned-issues-lane="true"
          :disabled="disabled"
          :can-admin-list="canAdminList"
        />
      </div>
    </div>
  </div>
</template>
