import { PARALLEL_DIFF_VIEW_TYPE, INLINE_DIFF_VIEW_TYPE } from '../constants';

export default {
  isParallelView: state => state.diffViewType === PARALLEL_DIFF_VIEW_TYPE,

  isInlineView: state => state.diffViewType === INLINE_DIFF_VIEW_TYPE,

  hasCollapsedFile: state => state.diffFiles.some(file => file.viewer && file.viewer.collapsed),

  commitId: state => (state.commit && state.commit.id ? state.commit.id : null),

  /**
   * Checks if the diff has all discussions expanded
   * @param {Object} diff
   * @returns {Boolean}
   */
  diffHasAllExpandedDiscussions: (state, getters) => diff => {
    const discussions = getters.getDiffFileDiscussions(diff);

    return (
      (discussions && discussions.length && discussions.every(discussion => discussion.expanded)) ||
      false
    );
  },

  /**
   * Checks if the diff has all discussions collapsed
   * @param {Object} diff
   * @returns {Boolean}
   */
  diffHasAllCollapsedDiscussions: (state, getters) => diff => {
    const discussions = getters.getDiffFileDiscussions(diff);

    return (
      (discussions &&
        discussions.length &&
        discussions.every(discussion => !discussion.expanded)) ||
      false
    );
  },

  /**
   * Checks if the diff has any open discussions
   * @param {Object} diff
   * @returns {Boolean}
   */
  diffHasExpandedDiscussions: (state, getters) => diff => {
    const discussions = getters.getDiffFileDiscussions(diff);

    return (
      (discussions &&
        discussions.length &&
        discussions.find(discussion => discussion.expanded) !== undefined) ||
      false
    );
  },

  /**
   * Checks if the diff has any discussion
   * @param {Boolean} diff
   * @returns {Boolean}
   */
  diffHasDiscussions: (state, getters) => diff => getters.getDiffFileDiscussions(diff).length > 0,

  /**
   * Returns an array with the discussions of the given diff
   * @param {Object} diff
   * @returns {Array}
   */
  getDiffFileDiscussions: (state, getters, rootState, rootGetters) => diff =>
    rootGetters.discussions.filter(
      discussion => discussion.diff_discussion && discussion.diff_file.file_hash === diff.file_hash,
    ) || [],

  // prevent babel-plugin-rewire from generating an invalid default during karma∂ tests
  getDiffFileByHash: state => fileHash => state.diffFiles.find(file => file.file_hash === fileHash),

  flatBlobsList: state => Object.values(state.treeEntries).filter(f => f.type === 'blob'),

  allBlobs: (state, getters) =>
    getters.flatBlobsList.reduce((acc, file) => {
      const { parentPath } = file;

      if (parentPath && !acc.some(f => f.path === parentPath)) {
        acc.push({
          path: parentPath,
          isHeader: true,
          tree: [],
        });
      }

      acc.find(f => f.path === parentPath).tree.push(file);

      return acc;
    }, []),

  diffFilesLength: state => state.diffFiles.length,

  getCommentFormForDiffFile: state => fileHash =>
    state.commentForms.find(form => form.fileHash === fileHash),

  /**
   * Returns index of a currently selected diff in diffFiles
   * @returns {number}
   */
  currentDiffIndex: state =>
    Math.max(0, state.diffFiles.findIndex(diff => diff.file_hash === state.currentDiffFileId)),
};
