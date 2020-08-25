<script>
import { MATCH_LINE_TYPE, LINE_POSITION_LEFT, LINE_POSITION_RIGHT } from '../constants';
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
  computed: {
    isMatchLineLeft() {
      return (
        this.line[LINE_POSITION_LEFT] && this.line[LINE_POSITION_LEFT].type === MATCH_LINE_TYPE
      );
    },
    isMatchLineRight() {
      return (
        this.line[LINE_POSITION_RIGHT] && this.line[LINE_POSITION_RIGHT].type === MATCH_LINE_TYPE
      );
    },
  },
  LINE_POSITION_LEFT,
};
</script>
<template>
  <tr class="line_expansion match">
    <template v-if="isMatchLineLeft || isMatchLineRight">
      <diff-expansion-cell
        :file-hash="fileHash"
        :context-lines-path="contextLinesPath"
        :line="line[$options.LINE_POSITION_LEFT]"
        :is-top="isTop"
        :is-bottom="isBottom"
        :colspan="6"
      />
    </template>
  </tr>
</template>
