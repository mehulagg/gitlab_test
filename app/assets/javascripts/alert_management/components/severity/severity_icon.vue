<script>
  import {  GlIcon } from '@gitlab/ui';
  import { ALERTS_SEVERITY_LABELS } from '../../constants';

  export default {
    severityLabels: ALERTS_SEVERITY_LABELS,
    components: {
      GlIcon
    },
    props: {
      severity: {
        type: String,
        required: true,
      },
    },
  };
</script>

<template>
  <div>
    <gl-icon
      class="gl-mr-3 align-middle"
      :size="12"
      :name="`severity-${severity.toLowerCase()}`"
      :class="`icon-${severity.toLowerCase()}`"
    />
    <strong>{{ $options.severityLabels[severity] }}</strong>
  </div>
</template>
