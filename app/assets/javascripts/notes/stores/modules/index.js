import * as actions from '../actions';
import * as getters from '../getters';
import mutations from '../mutations';

export default () => ({
  state: {
    discussions: [],
    convertedDisscussionIds: [],
    targetNoteHash: null,
    lastFetchedAt: null,
    currentDiscussionId: null,

    // View layer
    isToggleStateButtonLoading: false,
    isToggleBlockedIssueWarning: false,
    isNotesFetched: false,
    isLoading: true,

    // holds endpoints and permissions provided through haml
    notesData: {
      markdownDocsPath: '',
    },
    userData: {},
    noteableData: {
      current_user: {},
      preview_note_path: 'path/to/preview',
    },
    commentsDisabled: false,
    resolvableDiscussionsCount: 0,
    unresolvedDiscussionsCount: 0,
  },
  actions,
  getters,
  mutations,
});
