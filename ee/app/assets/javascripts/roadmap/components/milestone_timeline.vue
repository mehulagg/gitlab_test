<script>
import MilestoneItem from './milestone_item.vue';
import CurrentDayIndicator from './current_day_indicator.vue';

import { TIMELINE_CELL_MIN_WIDTH } from '../constants';

export default {
  components: {
    MilestoneItem,
    CurrentDayIndicator,
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
  <div>
    <span
      v-for="(timeframeItem, index) in timeframe"
      :key="index"
      class="milestone-timeline-cell"
      data-qa-selector="milestone_timeline_cell"
    >
      <current-day-indicator :preset-type="presetType" :timeframe-item="timeframeItem" />
      <milestone-item
        v-for="(milestone, index2) in milestones"
        :key="index2"
        :preset-type="presetType"
        :milestone="milestone"
        :timeframe="timeframe"
        :timeframe-item="timeframeItem"
        :current-group-id="currentGroupId"
      />
    </span>
  </div>
</template>
