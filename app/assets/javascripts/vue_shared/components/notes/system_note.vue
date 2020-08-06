<script>
/**
 * Common component to render a system note, icon and user information.
 *
 * This component needs to be used with a vuex store.
 * That vuex store needs to have a `targetNoteHash` getter
 *
 * @example
 * <system-note
 *   :note="{
 *     id: String,
 *     author: Object,
 *     createdAt: String,
 *     note_html: String,
 *     system_note_icon_name: String
 *    }"
 *   />
 */
import Api from '~/api';
import $ from 'jquery';
import { mapGetters, mapActions, mapState } from 'vuex';
import { GlDeprecatedButton, GlSkeletonLoading, GlTooltipDirective } from '@gitlab/ui';
import descriptionVersionHistoryMixin from 'ee_else_ce/notes/mixins/description_version_history';
import noteHeader from '~/notes/components/note_header.vue';
import Icon from '~/vue_shared/components/icon.vue';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import TimelineEntryItem from './timeline_entry_item.vue';
import { spriteIcon } from '../../../lib/utils/common_utils';
import initMRPopovers from '~/mr_popover/';
import NoteDiffLines from '~/notes/components/note_diff_lines.vue';
import { DIFF_NOTE_TYPE } from '~/diffs/constants';

const MAX_VISIBLE_COMMIT_LIST_COUNT = 3;

export default {
  name: 'SystemNote',
  components: {
    Icon,
    noteHeader,
    TimelineEntryItem,
    GlDeprecatedButton,
    GlSkeletonLoading,
    NoteDiffLines,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  mixins: [descriptionVersionHistoryMixin, glFeatureFlagsMixin()],
  props: {
    note: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      expanded: false,
      changedLines: undefined,
      changedLinesError: false,
      changedLinesExpanded: false,
    };
  },
  computed: {
    ...mapGetters(['targetNoteHash', 'descriptionVersions']),
    ...mapState(['isLoadingDescriptionVersion']),
    noteAnchorId() {
      return `note_${this.note.id}`;
    },
    isTargetNote() {
      return this.targetNoteHash === this.noteAnchorId;
    },
    iconHtml() {
      return spriteIcon(this.note.system_note_icon_name);
    },
    toggleIcon() {
      return this.expanded ? 'chevron-up' : 'chevron-down';
    },
    // following 2 methods taken from code in `collapseLongCommitList` of notes.js:
    actionTextHtml() {
      return $(this.noteHtmlStripped)
        .unwrap()
        .html();
    },
    hasMoreCommits() {
      return (
        $(this.note.note_html)
          .filter('ul')
          .children().length > MAX_VISIBLE_COMMIT_LIST_COUNT
      );
    },
    descriptionVersion() {
      return this.descriptionVersions[this.note.description_version_id];
    },
    noteHtmlStripped() {
      return this.note.note_html.replace(/<a href.*?>(.*)<\/a>/, (_, p1) => p1);
    },
    showChangedLines() {
      return this.changedLines && this.changedLinesExpanded;
    },
    isDiffNote() {
      return this.note.type === DIFF_NOTE_TYPE;
    },
  },
  mounted() {
    initMRPopovers(this.$el.querySelectorAll('.gfm-merge_request'));
  },
  methods: {
    ...mapActions(['fetchDescriptionVersion', 'softDeleteDescriptionVersion']),
    handleClickCompareButton() {
      if (!this.changedLines) this.getChangedLines();
      this.changedLinesExpanded = !this.changedLinesExpanded;
    },
    async getChangedLines() {
      try {
        this.changedLinesError = false;
        const startPosition = this.note.position.line_range.start;
        const endPosition = this.note.position.line_range.end;
        const url = /href="(.*)"/.exec(this.note.note_html);
        const changedLines = await Api.changedDiff(url[1]);
        const diffLines = changedLines.diff_files[0].highlighted_diff_lines;
        const getIndex = position => line => {
          if (!line.type === 'match') return false;
          if (line.type === 'old') return line.old_line === position.old_line;
          return line.new_line === position.new_line;
        };

        const startIndex = diffLines.findIndex(getIndex(startPosition));
        const endIndex = diffLines.findIndex(getIndex(endPosition));

        this.changedLines = changedLines.diff_files[0].highlighted_diff_lines.slice(
          startIndex,
          endIndex + 1,
        );
      } catch (err) {
        this.changedLinesError = true;
      }
    },
  },
};
</script>

<template>
  <timeline-entry-item
    :id="noteAnchorId"
    :class="{ target: isTargetNote, 'pr-0': shouldShowDescriptionVersion }"
    class="note system-note note-wrapper"
  >
    <div class="timeline-icon" v-html="iconHtml"></div>
    <div class="timeline-content">
      <div class="note-header">
        <note-header
          :author="note.author"
          :created-at="note.created_at"
          :note-id="note.id"
          :show-compare-button="isDiffNote"
          :on-click-compare-button="handleClickCompareButton"
        >
          <span v-html="actionTextHtml"></span>
          <template v-if="canSeeDescriptionVersion" slot="extra-controls">
            &#xB7;
            <button type="button" class="btn-blank btn-link" @click="toggleDescriptionVersion">
              {{ __('Compare with previous version') }}
              <icon :name="descriptionVersionToggleIcon" :size="12" class="append-left-5" />
            </button>
          </template>
        </note-header>
      </div>
      <div class="note-body">
        <div
          :class="{ 'system-note-commit-list': hasMoreCommits, 'hide-shade': expanded }"
          class="note-text md"
          v-html="note.note_html"
        ></div>
        <div v-if="hasMoreCommits" class="flex-list">
          <div class="system-note-commit-list-toggler flex-row" @click="expanded = !expanded">
            <icon :name="toggleIcon" :size="8" class="gl-mr-2" />
            <span>{{ __('Toggle commit list') }}</span>
          </div>
        </div>
        <div v-if="shouldShowDescriptionVersion" class="description-version pt-2">
          <pre v-if="isLoadingDescriptionVersion" class="loading-state">
            <gl-skeleton-loading />
          </pre>
          <pre v-else class="wrapper mt-2" v-html="descriptionVersion"></pre>
          <gl-deprecated-button
            v-if="displayDeleteButton"
            ref="deleteDescriptionVersionButton"
            v-gl-tooltip
            :title="__('Remove description history')"
            class="btn-transparent delete-description-history"
            @click="deleteDescriptionVersion"
          >
            <icon name="remove" />
          </gl-deprecated-button>
        </div>
      </div>
      <div
        v-if="showChangedLines"
        class="gl-mt-5 gl-mr-6 gl-mb-3 gl-ml-6 gl-border-solid gl-border-gray-100 gl-border-1"
      >
        <note-diff-lines
          :has-truncated-diff-lines="true"
          :lines="changedLines"
          :error="changedLinesError"
          :reload-diff-fn="getChangedLines"
        />
      </div>
    </div>
  </timeline-entry-item>
</template>
