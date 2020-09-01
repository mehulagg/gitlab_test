<script>
import { GlButton } from '@gitlab/ui';
import { __ } from '~/locale';
import { pikadayToString } from '~/lib/utils/datetime_utility';

export default {
  name: 'GroupRepositoryAnalytics',
  components: {
    GlButton,
  },
  props: {
    groupAnalyticsCoverageReportsPath: {
      type: String,
      required: true,
    },
  },
  computed: {
    csvReportPath() {
      const today = new Date();
      const endDate = pikadayToString(today);
      today.setFullYear(today.getFullYear() - 1);
      const startDate = pikadayToString(today);
      return `${this.groupAnalyticsCoverageReportsPath}&start_date=${startDate}&end_date=${endDate}`;
    },
  },
  text: {
    codeCoverageHeader: __('Test Code Coverage'),
    downloadCSVButton: __('Download historic test coverage data (.csv)'),
  },
};
</script>

<template>
  <div class="gl-display-flex gl-justify-content-space-between gl-align-items-center">
    <h4 class="sub-header">{{ $options.text.codeCoverageHeader }}</h4>
    <gl-button
      :href="csvReportPath"
      rel="nofollow"
      download
    >{{ $options.text.downloadCSVButton }}</gl-button>
  </div>
</template>
