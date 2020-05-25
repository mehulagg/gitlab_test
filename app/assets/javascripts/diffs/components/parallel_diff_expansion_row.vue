<script>
import DiffExpansionCell from './diff_expansion_cell.vue';

export default {
  components: {
    DiffExpansionCell,
  },
  props: {
    fileHash: {
      type: String,
      required: true,
    },
    contextLinesPath: {
      type: String,
      required: true,
    },
    line: {
      type: Object,
      required: true,
    },
    isTop: {
      type: Boolean,
      required: false,
      default: false,
    },
    isBottom: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
};
</script>

<template>
  <tr class="line_expansion match">
    <td colspan="6" class="text-center">
      <diff-expansion-cell
        :file-hash="fileHash"
        :context-lines-path="contextLinesPath"
        :line="line.left"
        :is-top="isTop"
        :is-bottom="isBottom"
      />
    </td>
  </tr>
</template>
