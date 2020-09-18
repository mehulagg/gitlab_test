<script>
import { GlDaterangePicker, GlButtonGroup, GlButton } from '@gitlab/ui';
import { sprintf, __, s__ } from '~/locale';
import { getDayDifference, getStartOfMonth, getDateInPast } from '~/lib/utils/datetime_utility';

const CURRENT_DATE = new Date();

export default {
  components: {
    GlButton,
    GlButtonGroup,
    GlDaterangePicker,
  },
  props: {
    startDate: {
      type: Date,
      required: false,
      default: null,
    },
    endDate: {
      type: Date,
      required: false,
      default: null,
    },
  },
  computed: {
    defaultStartDate() {
      return this.startDate || getStartOfMonth(CURRENT_DATE);
    },
    defaultEndDate() {
      return this.endDate || CURRENT_DATE;
    },
  },
  methods: {
    spanSelected({ date }) {
      this.onInput({
        startDate: date,
        endDate: CURRENT_DATE,
      });
    },
    onInput(dates) {
      this.$emit('selected', dates);
    },
    isStartingDate(selectedDate) {
      return getDayDifference(selectedDate, this.defaultStartDate) === 0;
    },
  },
  CURRENT_DATE,
  maxDateRange: 31,
  timeSpans: [
    { label: sprintf(__('Last %{days} days'), { days: 7 }), date: getDateInPast(CURRENT_DATE, 7) },
    {
      label: sprintf(__('Last %{days} days'), { days: 14 }),
      date: getDateInPast(CURRENT_DATE, 14),
    },
    { label: s__('ContributionAnalytics|Last month'), date: getStartOfMonth(CURRENT_DATE) },
  ],
};
</script>

<template>
  <div class="d-flex">
    <div class="gl-pr-5">
      <gl-button-group>
        <gl-button
          v-for="(span, idx) in $options.timeSpans"
          :selected="isStartingDate(span.date)"
          @click="spanSelected(span)"
          :key="idx"
          >{{ span.label }}</gl-button
        >
      </gl-button-group>
    </div>
    <gl-daterange-picker
      class="d-flex flex-wrap flex-sm-nowrap"
      :default-start-date="defaultStartDate"
      :default-end-date="defaultEndDate"
      :default-max-date="$options.CURRENT_DATE"
      :max-date-range="$options.maxDateRange"
      start-picker-class="form-group align-items-lg-center mr-0 mr-sm-1 d-flex flex-column flex-lg-row"
      end-picker-class="form-group align-items-lg-center mr-0 mr-sm-2 d-flex flex-column flex-lg-row"
      @input="onInput"
    />
  </div>
</template>
