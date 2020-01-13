<script>
import MilestoneItem from './milestone_item.vue';

import { TIMELINE_CELL_MIN_WIDTH } from '../constants';

export default {
  components: {
    MilestoneItem,
  },
  cellWidth: TIMELINE_CELL_MIN_WIDTH,
  props: {
    presetType: {
      type: String,
      required: true,
    },
    timeframe: {
      type: Array,
      required: true,
    },
    timeframeItem: {
      type: [Date, Object],
      required: true,
    },
    milestones: {
      type: Array,
      required: true,
    },
    currentGroupId: {
      type: Number,
      required: true,
    },
  },
};
</script>

<template>
  <span class="milestone-timeline-cell" data-qa-selector="milestone_timeline_cell">
    <milestone-item
      v-for="(milestone, index) in milestones"
      :key="index"
      :preset-type="presetType"
      :milestone="milestone"
      :timeframe="timeframe"
      :timeframe-item="timeframeItem"
      :current-group-id="currentGroupId"
    />
  </span>
</template>
