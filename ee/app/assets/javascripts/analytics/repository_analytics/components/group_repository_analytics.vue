<script>
import { GlButton } from '@gitlab/ui';
import { __ } from '~/locale';

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
  text: {
    codeCoverageHeader: __('Test Code Coverage'),
    downloadCSVButton: __('Download historic test coverage data (.csv)'),
  },
};
</script>

<template>
  <div class="d-flex justify-content-between align-items-center">
    <h4 class="sub-header">{{ $options.text.codeCoverageHeader }}</h4>
    <gl-button
      :href="groupAnalyticsCoverageReportsPath"
      rel="nofollow"
      download
      size="small"
    >{{ $options.text.downloadCSVButton }}</gl-button>
  </div>
</template>
