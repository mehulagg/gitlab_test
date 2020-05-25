<script>
import { mapGetters, mapState } from 'vuex';
import draftCommentsMixin from '~/diffs/mixins/draft_comments';
import ParallelDraftCommentRow from '~/batch_comments/components/parallel_draft_comment_row.vue';
import parallelDiffTableRow from './parallel_diff_table_row.vue';
import parallelDiffCommentRow from './parallel_diff_comment_row.vue';
import parallelDiffExpansionRow from './parallel_diff_expansion_row.vue';
import { getCommentedLines } from '~/notes/components/multiline_comment_utils';

export default {
  components: {
    parallelDiffExpansionRow,
    parallelDiffTableRow,
    parallelDiffCommentRow,
    ParallelDraftCommentRow: () =>
      import('ee_component/batch_comments/components/parallel_draft_comment_row.vue'),
  },
  mixins: [draftCommentsMixin],
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
  computed: {
    ...mapGetters('diffs', ['commitId']),
    ...mapState({
      selectedCommentPosition: ({ notes }) => notes.selectedCommentPosition,
      selectedCommentPositionHover: ({ notes }) => notes.selectedCommentPositionHover,
    }),
    diffLinesLength() {
      return this.diffLines.length;
    },
    commentedLines() {
      return getCommentedLines(
        this.selectedCommentPosition || this.selectedCommentPositionHover,
        this.diffLines,
      );
    },
  },
  methods: {
    isMatchLine(line) {
      return line.left?.type === MATCH_LINE_TYPE || line.right?.type === MATCH_LINE_TYPE;
    },
    shouldRenderCommentRow({ left, right }) {
      if (
        (left?.discussions?.length && left?.discussionsExpanded) ||
        (right?.discussions?.length && right?.discussionsExpanded)
      )
        return true;
      return left?.hasForm || right?.hasForm;
    },
  },
  userColorScheme: window.gon.user_color_scheme,
};
</script>

<template>
  <table
    :class="$options.userColorScheme"
    :data-commit-id="commitId"
    class="code diff-wrap-lines js-syntax-highlight text-file"
  >
    <colgroup>
      <col style="width: 50px;" />
      <col style="width: 8px;" />
      <col />
      <col style="width: 50px;" />
      <col style="width: 8px;" />
      <col />
    </colgroup>
    <tbody>
      <template v-for="(line, index) in diffLines">
        <parallel-diff-expansion-row
          v-if="isMatchLine(line)"
          :key="`expand-${index}`"
          :file-hash="diffFile.file_hash"
          :context-lines-path="diffFile.context_lines_path"
          :line="line"
          :is-top="index === 0"
          :is-bottom="index + 1 === diffLinesLength"
        />
        <parallel-diff-table-row
          :key="line.line_code"
          :file-hash="diffFile.file_hash"
          :file-path="diffFile.file_path"
          :context-lines-path="diffFile.context_lines_path"
          :line="line"
          :is-bottom="index + 1 === diffLinesLength"
          :is-commented="index >= commentedLines.startLine && index <= commentedLines.endLine"
        />
        <parallel-diff-comment-row
          v-if="shouldRenderCommentRow(line)"
          :key="`dcr-${line.line_code || index}`"
          :line="line"
          :diff-file-hash="diffFile.file_hash"
          :line-index="index"
          :help-page-path="helpPagePath"
          :has-draft-left="hasParallelDraftLeft(diffFile.file_hash, line) || false"
          :has-draft-right="hasParallelDraftRight(diffFile.file_hash, line) || false"
        />
        <parallel-draft-comment-row
          v-if="shouldRenderParallelDraftRow(diffFile.file_hash, line)"
          :key="`drafts-${index}`"
          :line="line"
          :diff-file-content-sha="diffFile.file_hash"
        />
      </template>
    </tbody>
  </table>
</template>
