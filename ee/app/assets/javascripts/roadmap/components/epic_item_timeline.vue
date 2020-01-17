<script>
import { GlPopover, GlProgressBar } from '@gitlab/ui';
import { __, sprintf } from '~/locale';
import icon from '~/vue_shared/components/icon.vue';
import { generateKey } from '../utils/epic_utils';

import QuartersPresetMixin from '../mixins/quarters_preset_mixin';
import MonthsPresetMixin from '../mixins/months_preset_mixin';
import WeeksPresetMixin from '../mixins/weeks_preset_mixin';

import {
  EPIC_DETAILS_CELL_WIDTH,
  TIMELINE_CELL_MIN_WIDTH,
  PERCENTAGE,
  PRESET_TYPES,
  SMALL_TIMELINE_BAR,
  VERY_SMALL_TIMELINE_BAR,
} from '../constants';

export default {
  cellWidth: TIMELINE_CELL_MIN_WIDTH,
  components: {
    icon,
    GlPopover,
    GlProgressBar,
  },
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
    timeframeItem: {
      type: [Date, Object],
      required: true,
    },
    epic: {
      type: Object,
      required: true,
    },
    timeframeString: {
      type: String,
      required: true,
    },
    clientWidth: {
      type: Number,
      required: true,
    },
  },
  computed: {
    epicStartDateValues() {
      const { startDate } = this.epic;

      return {
        day: startDate.getDay(),
        date: startDate.getDate(),
        month: startDate.getMonth(),
        year: startDate.getFullYear(),
        time: startDate.getTime(),
      };
    },
    epicEndDateValues() {
      const { endDate } = this.epic;

      return {
        day: endDate.getDay(),
        date: endDate.getDate(),
        month: endDate.getMonth(),
        year: endDate.getFullYear(),
        time: endDate.getTime(),
      };
    },
    hasStartDate() {
      if (this.presetType === PRESET_TYPES.QUARTERS) {
        return this.hasStartDateForQuarter();
      } else if (this.presetType === PRESET_TYPES.MONTHS) {
        return this.hasStartDateForMonth();
      } else if (this.presetType === PRESET_TYPES.WEEKS) {
        return this.hasStartDateForWeek();
      }
      return false;
    },
    timelineBarStyles() {
      let barStyles = {};

      if (this.hasStartDate) {
        if (this.presetType === PRESET_TYPES.QUARTERS) {
          // CSS properties are a false positive: https://gitlab.com/gitlab-org/frontend/eslint-plugin-i18n/issues/24
          // eslint-disable-next-line @gitlab/i18n/no-non-i18n-strings
          barStyles = `width: ${this.getTimelineBarWidthForQuarters()}px; ${this.getTimelineBarStartOffsetForQuarters()}`;
        } else if (this.presetType === PRESET_TYPES.MONTHS) {
          // eslint-disable-next-line @gitlab/i18n/no-non-i18n-strings
          barStyles = `width: ${this.getTimelineBarWidthForMonths()}px; ${this.getTimelineBarStartOffsetForMonths()}`;
        } else if (this.presetType === PRESET_TYPES.WEEKS) {
          // eslint-disable-next-line @gitlab/i18n/no-non-i18n-strings
          barStyles = `width: ${this.getTimelineBarWidthForWeeks()}px; ${this.getTimelineBarStartOffsetForWeeks()}`;
        }
      }
      return barStyles;
    },
    epicBarInnerStyle() {
      return {
        maxWidth: `${this.clientWidth - EPIC_DETAILS_CELL_WIDTH}px`,
      };
    },
    timelineBarWidth() {
      if (this.hasStartDate) {
        if (this.presetType === PRESET_TYPES.QUARTERS) {
          return this.getTimelineBarWidthForQuarters();
        } else if (this.presetType === PRESET_TYPES.MONTHS) {
          return this.getTimelineBarWidthForMonths();
        } else if (this.presetType === PRESET_TYPES.WEEKS) {
          return this.getTimelineBarWidthForWeeks();
        }
      }
      return Infinity;
    },
    showTimelineBarEllipsis() {
      return this.timelineBarWidth < SMALL_TIMELINE_BAR;
    },
    timelineBarEllipsis() {
      if (this.timelineBarWidth < VERY_SMALL_TIMELINE_BAR) {
        return '.';
      } else if (this.timelineBarWidth < SMALL_TIMELINE_BAR) {
        return '...';
      }
      return '';
    },
    epicTotalWeight() {
      if (this.epic.descendantWeightSum) {
        const { openedIssues, closedIssues } = this.epic.descendantWeightSum;
        return openedIssues + closedIssues;
      }
      return undefined;
    },
    epicWeightPercentage() {
      return this.epicTotalWeight
        ? Math.round(
            (this.epic.descendantWeightSum.closedIssues / this.epicTotalWeight) * PERCENTAGE,
          )
        : 0;
    },
    popoverWeightText() {
      if (this.epic.descendantWeightSum) {
        return sprintf(__('%{completedWeight} of %{totalWeight} weight completed'), {
          completedWeight: this.epic.descendantWeightSum.closedIssues,
          totalWeight: this.epicTotalWeight,
        });
      }
      return __('- of - weight completed');
    },
  },
  methods: {
    generateKey,
  }
};
</script>

<template>
  <span class="epic-timeline-cell" data-qa-selector="epic_timeline_cell">
    <div class="epic-bar-wrapper">
      <a
        v-if="hasStartDate"
        :id="generateKey(epic)"
        :href="epic.webUrl"
        :style="timelineBarStyles"
        class="epic-bar"
        :class="{ 'epic-bar-sub-epic': epic.isSubEpic }"
      >
        <div class="epic-bar-inner" :style="epicBarInnerStyle">
          <gl-progress-bar
            class="epic-bar-progress append-bottom-2"
            :value="epicWeightPercentage"
          />

          <div v-if="showTimelineBarEllipsis" class="m-0">{{ timelineBarEllipsis }}</div>
          <div v-else class="d-flex">
            <span class="flex-grow-1 text-nowrap text-truncate append-right-16">{{
              epic.description
            }}</span>
            <span class="d-flex align-items-center text-nowrap">
              <icon class="append-right-2" :size="16" name="weight" />
              {{ epicWeightPercentage }}%
            </span>
          </div>
        </div>
      </a>
      <gl-popover
        :target="generateKey(epic)"
        :title="epic.description"
        triggers="hover focus"
        placement="right"
      >
        <p class="text-secondary m-0">{{ timeframeString }}</p>
        <p class="m-0">{{ popoverWeightText }}</p>
      </gl-popover>
    </div>
  </span>
</template>
