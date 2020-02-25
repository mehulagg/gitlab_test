<script>
import CommonMixin from '../mixins/common_mixin';

export default {
  mixins: [CommonMixin],
  props: {
    epic: {
      type: Object,
      required: true,
    },
    currentGroupId: {
      type: Number,
      required: true,
    },
  },
  computed: {
    isEpicGroupDifferent() {
      return this.currentGroupId !== this.epic.groupId;
    },
    /**
     * In case Epic start date is out of range
     * we need to use original date instead of proxy date
     */
    startDate() {
      if (this.epic.startDateOutOfRange) {
        return this.epic.originalStartDate;
      }

      return this.epic.startDate;
    },
    /**
     * In case Epic end date is out of range
     * we need to use original date instead of proxy date
     */
    endDate() {
      if (this.epic.endDateOutOfRange) {
        return this.epic.originalEndDate;
      }
      return this.epic.endDate;
    },
  },
};
</script>

<template>
  <span class="epic-details-cell" data-qa-selector="epic_details_cell">
    <div class="epic-title">
      <a :href="epic.webUrl" :title="epic.title" class="epic-url">{{ epic.title }}</a>
    </div>
    <div class="epic-group-timeframe">
      <span v-if="isEpicGroupDifferent" :title="epic.groupFullName" class="epic-group"
        >{{ epic.groupName }} &middot;</span
      >
      <span class="epic-timeframe" v-html="timeframeString(epic)"></span>
    </div>
  </span>
</template>
