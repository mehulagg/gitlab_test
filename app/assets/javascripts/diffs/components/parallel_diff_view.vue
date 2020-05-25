<script>
import parallelDiffTable from './parallel_diff_table.vue';

export default {
  components: { parallelDiffTable },
  props: {
    diffFile: {
      type: Object,
      required: true,
    },
    diffLines: {
      type: Array,
      required: true,
    },
    helpPagePath: {
      type: String,
      required: false,
      default: '',
    },
  },
};
</script>

<template>
  <parallel-diff-table
    :diff-lines="diffLines"
    :diff-file="diffFile"
    :help-page-path="helpPagePath"
  />
</template>
