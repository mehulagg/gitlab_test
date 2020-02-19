<script>
import { s__, sprintf } from '~/locale';

import { GlPopover } from '@gitlab/ui';

import CommonMixin from '../mixins/common_mixin';
import QuartersPresetMixin from '../mixins/quarters_preset_mixin';
import MonthsPresetMixin from '../mixins/months_preset_mixin';
import WeeksPresetMixin from '../mixins/weeks_preset_mixin';

import { TIMELINE_CELL_MIN_WIDTH, SCROLL_BAR_SIZE } from '../constants';

import { dateInWords } from '~/lib/utils/datetime_utility';

export default {
  cellWidth: TIMELINE_CELL_MIN_WIDTH,
  components: {
    GlPopover,
  },
  mixins: [CommonMixin, QuartersPresetMixin, MonthsPresetMixin, WeeksPresetMixin],
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
  data() {
    return {
      hoverStyles: {},
    };
  },
  computed: {
    startDateValues() {
      const { startDate } = this.milestone;

      return {
        day: startDate.getDay(),
        date: startDate.getDate(),
        month: startDate.getMonth(),
        year: startDate.getFullYear(),
        time: startDate.getTime(),
      };
    },
    endDateValues() {
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
      if (this.presetTypeQuarters) {
        return this.hasStartDateForQuarter();
      } else if (this.presetTypeMonths) {
        return this.hasStartDateForMonth();
      } else if (this.presetTypeWeeks) {
        return this.hasStartDateForWeek();
      }
      return false;
    },
    timelineBarStyles() {
      let barStyles = {};

      if (this.hasStartDate) {
        if (this.presetTypeQuarters) {
          // CSS properties are a false positive: https://gitlab.com/gitlab-org/frontend/eslint-plugin-i18n/issues/24
          // eslint-disable-next-line @gitlab/i18n/no-non-i18n-strings
          barStyles = `width: ${this.getTimelineBarWidthForQuarters(
            this.milestone,
          )}px; ${this.getTimelineBarStartOffsetForQuarters(this.milestone)}`;
        } else if (this.presetTypeMonths) {
          // eslint-disable-next-line @gitlab/i18n/no-non-i18n-strings
          barStyles = `width: ${this.getTimelineBarWidthForMonths()}px; ${this.getTimelineBarStartOffsetForMonths(
            this.milestone,
          )}`;
        } else if (this.presetTypeWeeks) {
          // eslint-disable-next-line @gitlab/i18n/no-non-i18n-strings
          barStyles = `width: ${this.getTimelineBarWidthForWeeks()}px; ${this.getTimelineBarStartOffsetForWeeks(
            this.milestone,
          )}`;
        }
      }
      return barStyles;
    },
    /**
     * In case Milestone start date is out of range
     * we need to use original date instead of proxy date
     */
    startDate() {
      if (this.milestone.startDateOutOfRange) {
        return this.milestone.originalStartDate;
      }

      return this.milestone.startDate;
    },
    /**
     * In case Milestone end date is out of range
     * we need to use original date instead of proxy date
     */
    endDate() {
      if (this.milestone.endDateOutOfRange) {
        return this.milestone.originalEndDate;
      }
      return this.milestone.endDate;
    },
    /**
     * Compose timeframe string to show on UI
     * based on start and end date availability
     */
    timeframeString() {
      if (this.milestone.startDateUndefined) {
        return sprintf(s__('GroupRoadmap|Until %{dateWord}'), {
          dateWord: dateInWords(this.endDate, true),
        });
      } else if (this.milestone.endDateUndefined) {
        return sprintf(s__('GroupRoadmap|From %{dateWord}'), {
          dateWord: dateInWords(this.startDate, true),
        });
      }

      // In case both start and end date fall in same year
      // We should hide year from start date
      const startDateInWords = dateInWords(
        this.startDate,
        true,
        this.startDate.getFullYear() === this.endDate.getFullYear(),
      );

      const endDateInWords = dateInWords(this.endDate, true);
      return sprintf(s__('GroupRoadmap|%{startDateInWords} - %{endDateInWords}'), {
        startDateInWords,
        endDateInWords,
      });
    },
  },
  mounted() {
    this.$nextTick(() => {
      this.hoverStyles = this.getHoverStyles();
    });
  },
  methods: {
    getHoverStyles() {
      const elHeight = this.$root.$el.getBoundingClientRect().y;
      return {
        height: `calc(100vh - ${elHeight + SCROLL_BAR_SIZE}px)`,
      };
    },
  },
};
</script>

<template>
  <div class="timeline-bar-wrapper">
    <span
      v-if="hasStartDate"
      :class="{
        'start-date-undefined': milestone.startDateUndefined,
        'end-date-undefined': milestone.endDateUndefined,
      }"
      :style="timelineBarStyles"
      class="milestone-item-details"
    >
      <a :id="`milestone-item-${milestone.id}`" :href="milestone.webPath" class="milestone-url">
        <span class="timeline-bar"></span>
        <span class="milestone-item-title">{{ milestone.title }}</span>
      </a>
      <div class="milestone-start-and-end" :style="hoverStyles"></div>
      <gl-popover
        :target="`milestone-item-${milestone.id}`"
        boundary="viewport"
        placement="top"
        triggers="hover"
        :title="milestone.title"
      >
        <!-- TODO - Add group, subgroup or project  -->
        {{ timeframeString }}
      </gl-popover>
    </span>
  </div>
</template>
