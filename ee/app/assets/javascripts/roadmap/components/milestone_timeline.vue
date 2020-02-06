<script>
import MilestoneItem from './milestone_item.vue';

import { TIMELINE_CELL_MIN_WIDTH, PRESET_TYPES } from '../constants';

import QuartersPresetMixin from '../mixins/quarters_preset_mixin';
import MonthsPresetMixin from '../mixins/months_preset_mixin';
import WeeksPresetMixin from '../mixins/weeks_preset_mixin';

import { timeframeDate } from '../utils/milestone_utils';

export default {
  components: {
    MilestoneItem,
  },
  cellWidth: TIMELINE_CELL_MIN_WIDTH,
  mixins: [QuartersPresetMixin, MonthsPresetMixin, WeeksPresetMixin],
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
  computed: {
    milestonesPerTimeframeItem() {
      const milestonesPerTimeframeItem = {};
      let previousTimeFrameItem = this.timeframe[0];
      this.timeframe.forEach((timeframeItem, timeIndex) => {
        const linesForMilestones = {};
        let previousLinesForMilestones = {};
        if (timeIndex > 0) {
          previousLinesForMilestones = milestonesPerTimeframeItem[this.timeframeToDate(previousTimeFrameItem)];
        }
        this.milestones.forEach((milestone) => {
          if (this.hasStartDate(milestone, timeframeItem)) {
            let milestoneWillStack = false;
            Object.keys(previousLinesForMilestones).forEach(lineIndex => {
              const line = previousLinesForMilestones[lineIndex];
              line.forEach(prevMilestone => {
                // Can milestone be stacked next to another from previous timeframeItem
                if (this.hasEndDate(prevMilestone, timeframeItem) && prevMilestone.endDate.getTime() < milestone.startDate.getTime()) {
                  if (linesForMilestones[lineIndex]) { linesForMilestones[lineIndex].push(milestone); }
                  else { linesForMilestones[lineIndex] = [milestone]; }
                  milestoneWillStack = true;
                }
                else if (linesForMilestones[lineIndex]) {
                  linesForMilestones[lineIndex].push(prevMilestone);
                }
                else {
                  linesForMilestones[lineIndex] = [prevMilestone];
                }
              });
            });
            if (!milestoneWillStack) {
              let milestoneWillStackCurrent = false;
              // Can milestone be stacked next to another from current timeframeItem
              Object.keys(linesForMilestones).forEach(curentLineIndex => {
                const currentLine = linesForMilestones[curentLineIndex];
                currentLine.forEach(currentMilestone => {
                  if (this.hasEndDate(currentMilestone, timeframeItem) && currentMilestone.endDate.getTime() < milestone.startDate.getTime()) {
                    if (linesForMilestones[curentLineIndex]) linesForMilestones[curentLineIndex].push(milestone);
                    else linesForMilestones[curentLineIndex] = [milestone];
                    milestoneWillStackCurrent = true;
                  }
                });
              });
              if (!milestoneWillStackCurrent) {
                linesForMilestones[Object.keys(linesForMilestones).length] = [milestone];
              }
            }
          }
        });
        const date = this.timeframeToDate(timeframeItem);
        milestonesPerTimeframeItem[date] = linesForMilestones;
        previousTimeFrameItem = timeframeItem;
      });
      return milestonesPerTimeframeItem;
    },
  },
  methods: {
    timeframeToDate(timeframeItem) {
      return timeframeDate(timeframeItem, this.presetType);
    },
    hasStartDate(milestone, timeframeItem) {
      if (this.presetType === PRESET_TYPES.QUARTERS) {
        return this.startsInQuarter(milestone, timeframeItem);
      } else if (this.presetType === PRESET_TYPES.MONTHS) {
        return this.startsInMonth(milestone, timeframeItem);
      } else if (this.presetType === PRESET_TYPES.WEEKS) {
        return this.startsInWeek(milestone, timeframeItem);
      }
      return false;
    },
    hasEndDate(milestone, timeframeItem) {
      if (this.presetType === PRESET_TYPES.QUARTERS) {
        return this.endsInQuarter(milestone, timeframeItem);
      } else if (this.presetType === PRESET_TYPES.MONTHS) {
        return this.endsInMonth(milestone, timeframeItem);
      } else if (this.presetType === PRESET_TYPES.WEEKS) {
        return this.endsInWeek(milestone, timeframeItem);
      }
      return false;
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
      <template v-if="milestonesPerTimeframeItem[timeframeToDate(timeframeItem)]">
        <div
          v-for="(line, index2) in milestonesPerTimeframeItem[timeframeToDate(timeframeItem)]"
          :key="index2"
          class="timeline-bar-wrapper"
        >
          <milestone-item
            v-for="(milestone, index3) in line"
            :key="index3"
            :preset-type="presetType"
            :milestone="milestone"
            :timeframe="timeframe"
            :timeframe-item="timeframeItem"
            :current-group-id="currentGroupId"
          />
        </div>
      </template>
    </span>
  </div>
</template>
