import { parallelLineKey, showDraftOnSide } from '../../../utils';

export default {
  draftsCount: state => state.drafts.length,

  getNotesData: (state, getters, rootState, rootGetters) => rootGetters.getNotesData,

  hasDrafts: state => state.drafts.length > 0,

  draftsPerDiscussionId: state =>
    state.drafts.reduce((acc, draft) => {
      if (draft.discussion_id) {
        acc[draft.discussion_id] = draft;
      }

      return acc;
    }, {}),

  draftsPerFileHashAndLine: state =>
    state.drafts.reduce((acc, draft) => {
      if (draft.file_hash) {
        if (!acc[draft.file_hash]) {
          acc[draft.file_hash] = {};
        }

        acc[draft.file_hash][draft.line_code] = draft;
      }

      return acc;
    }, {}),

  shouldRenderDraftRow: (state, getters) => (diffFileSha, line) =>
    !!(
      diffFileSha in getters.draftsPerFileHashAndLine &&
      getters.draftsPerFileHashAndLine[diffFileSha][line.line_code]
    ),

  shouldRenderParallelDraftRow: (state, getters) => (diffFileSha, line) => {
    const draftsForFile = getters.draftsPerFileHashAndLine[diffFileSha];
    const [lkey, rkey] = [parallelLineKey(line, 'left'), parallelLineKey(line, 'right')];

    return draftsForFile ? !!(draftsForFile[lkey] || draftsForFile[rkey]) : false;
  },

  shouldRenderDraftRowInDiscussion: (state, getters) => discussionId =>
    typeof getters.draftsPerDiscussionId[discussionId] !== 'undefined',

  draftForDiscussion: (state, getters) => discussionId =>
    getters.draftsPerDiscussionId[discussionId] || {},

  draftForLine: (state, getters) => (diffFileSha, line, side = null) => {
    const draftsForFile = getters.draftsPerFileHashAndLine[diffFileSha];

    const key = side !== null ? parallelLineKey(line, side) : line.line_code;

    if (draftsForFile) {
      const draft = draftsForFile[key];
      if (draft && showDraftOnSide(line, side)) {
        return draft;
      }
    }
    return {};
  },

  isPublishingDraft: state => draftId => state.currentlyPublishingDrafts.indexOf(draftId) !== -1,

  sortedDrafts: state => [...state.drafts].sort((a, b) => a.id > b.id),
};
