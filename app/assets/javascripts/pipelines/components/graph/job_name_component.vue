<script>
import ciIcon from '../../../vue_shared/components/ci_icon.vue';

/**
 * Component that renders both the CI icon status and the job name.
 * Used in
 *  - Badge component
 *  - Dropdown badge components
 */
export default {
  components: {
    ciIcon,
  },
  props: {
    name: {
      type: String,
      required: true,
    },

    status: {
      type: Object,
      required: true,
    },
  },
};
</script>
<template>
  <span class="ci-job-name-component mw-100 d-flex flex-row align-items-center">
    <ci-icon :status="status" />
    <span class="ci-status-text text-truncate mw-70p gl-pl-2 flex-grow-1">
      {{ name }}
    </span>
  </span>
</template>
