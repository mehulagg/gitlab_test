<script>
import { GlPopover } from '@gitlab/ui';

import QuartersPresetMixin from '../mixins/quarters_preset_mixin';
import MonthsPresetMixin from '../mixins/months_preset_mixin';
import WeeksPresetMixin from '../mixins/weeks_preset_mixin';

import { TIMELINE_CELL_MIN_WIDTH, PRESET_TYPES } from '../constants';

export default {
  cellWidth: TIMELINE_CELL_MIN_WIDTH,
  components: {
    GlPopover,
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
    milestone: {
      type: Object,
      required: true,
    },
  },
  computed: {
    // TODO: Mixins should be more generic - currently specific to epics
    epicStartDateValues() {
      const { startDate } = this.milestone;

      return {
        day: startDate.getDay(),
        date: startDate.getDate(),
        month: startDate.getMonth(),
        year: startDate.getFullYear(),
        time: startDate.getTime(),
      };
    },
    epicEndDateValues() {
      const { endDate } = this.milestone;

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
          barStyles = `width: ${this.getTimelineBarWidthForQuarters(
            this.milestone,
          )}px; ${this.getTimelineBarStartOffsetForQuarters(this.milestone)}`;
        } else if (this.presetType === PRESET_TYPES.MONTHS) {
          // eslint-disable-next-line @gitlab/i18n/no-non-i18n-strings
          barStyles = `width: ${this.getTimelineBarWidthForMonths()}px; ${this.getTimelineBarStartOffsetForMonths(
            this.milestone,
          )}`;
        } else if (this.presetType === PRESET_TYPES.WEEKS) {
          // eslint-disable-next-line @gitlab/i18n/no-non-i18n-strings
          barStyles = `width: ${this.getTimelineBarWidthForWeeks()}px; ${this.getTimelineBarStartOffsetForWeeks()}`;
        }
      }
      return barStyles;
    },
  },
};
</script>

<template>
  <div v-if="hasStartDate" :id="`milestone-item-${milestone.id}`" class="timeline-bar-wrapper">
    <a
      :href="milestone.webUrl"
      :class="{
        'start-date-undefined': milestone.startDateUndefined,
        'end-date-undefined': milestone.endDateUndefined,
      }"
      :style="timelineBarStyles"
      class="timeline-bar"
    >
      <span class="milestone-item-title">{{ milestone.title }}</span>
    </a>
    <gl-popover
      :target="`milestone-item-${milestone.id}`"
      boundary="viewport"
      placement="top"
      triggers="hover"
      :title="milestone.title"
    >
      <!-- TODO - move timeframeString epic function to util for reusability  -->
      Temporary
    </gl-popover>
  </div>
</template>
