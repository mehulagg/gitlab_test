<script>
import inlineDiffTable from './inline_diff_table.vue';

export default {
  components: {
    inlineDiffTable,
  },
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
  <inline-diff-table :diff-lines="diffLines" :diff-file="diffFile" :help-page-path="helpPagePath" />
</template>
