<script>
import { mapGetters, mapState, mapActions } from 'vuex';
import IdeTreeList from './ide_tree_list.vue';
import EditorModeDropdown from './editor_mode_dropdown.vue';
import { viewerTypes } from '../constants';

export default {
  components: {
    IdeTreeList,
    EditorModeDropdown,
  },
  computed: {
    ...mapGetters(['currentMergeRequest', 'activeFile']),
    ...mapState(['viewer', 'currentMergeRequestId']),
    showLatestChangesText() {
      return !this.currentMergeRequestId || this.viewer === viewerTypes.diff;
    },
    showMergeRequestText() {
      return this.currentMergeRequestId && this.viewer === viewerTypes.mr;
    },
    mergeRequestId() {
      return `!${this.currentMergeRequest.iid}`;
    },
  },
  mounted() {
    if (this.activeFile && this.activeFile.pending && !this.activeFile.deleted) {
      this.$router.push(`/project${this.activeFile.url}`, () => {
        this.updateViewer('editor');
      });
    } else if (this.activeFile && this.activeFile.deleted) {
      this.resetOpenFiles();
    }

    this.$nextTick(() => {
      this.updateViewer(this.currentMergeRequestId ? viewerTypes.mr : viewerTypes.diff);
    });
  },
  methods: {
    ...mapActions(['updateViewer', 'resetOpenFiles']),
  },
};
</script>

<template>
  <ide-tree-list :viewer-type="viewer" header-class="ide-review-header">
    <template slot="header">
      <editor-mode-dropdown
        :viewer="viewer"
        :merge-request-id="currentMergeRequest.iid"
        @click="updateViewer"
      />
    </template>
  </ide-tree-list>
</template>
