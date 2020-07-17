import mutationsCE from '~/boards/stores/mutations';
import * as mutationTypes from './mutation_types';

const notImplemented = () => {
  /* eslint-disable-next-line @gitlab/require-i18n-strings */
  throw new Error('Not implemented!');
};

export default {
  ...mutationsCE,
  [mutationTypes.SET_SHOW_LABELS]: (state, val) => {
    state.isShowingLabels = val;
  },
  [mutationTypes.SET_ACTIVE_LIST_ID]: (state, id) => {
    state.activeListId = id;
  },

  [mutationTypes.REQUEST_AVAILABLE_BOARDS]: () => {
    notImplemented();
  },

  [mutationTypes.RECEIVE_AVAILABLE_BOARDS_SUCCESS]: () => {
    notImplemented();
  },

  [mutationTypes.RECEIVE_AVAILABLE_BOARDS_ERROR]: () => {
    notImplemented();
  },

  [mutationTypes.REQUEST_RECENT_BOARDS]: () => {
    notImplemented();
  },

  [mutationTypes.RECEIVE_RECENT_BOARDS_SUCCESS]: () => {
    notImplemented();
  },

  [mutationTypes.RECEIVE_RECENT_BOARDS_ERROR]: () => {
    notImplemented();
  },

  [mutationTypes.REQUEST_ADD_BOARD]: () => {
    notImplemented();
  },

  [mutationTypes.RECEIVE_ADD_BOARD_SUCCESS]: () => {
    notImplemented();
  },

  [mutationTypes.RECEIVE_ADD_BOARD_ERROR]: () => {
    notImplemented();
  },

  [mutationTypes.REQUEST_REMOVE_BOARD]: () => {
    notImplemented();
  },

  [mutationTypes.RECEIVE_REMOVE_BOARD_SUCCESS]: () => {
    notImplemented();
  },

  [mutationTypes.RECEIVE_REMOVE_BOARD_ERROR]: () => {
    notImplemented();
  },

  [mutationTypes.TOGGLE_PROMOTION_STATE]: () => {
    notImplemented();
  },

  [mutationTypes.TOGGLE_EPICS_SWIMLANES]: state => {
    state.isShowingEpicsSwimlanes = !state.isShowingEpicsSwimlanes;
    state.epicsSwimlanesFetchInProgress = true;
  },

  [mutationTypes.RECEIVE_BOARD_LISTS_SUCCESS]: (state, boardLists) => {
    state.boardLists = boardLists;
    state.epicsSwimlanesFetchInProgress = false;
  },

  [mutationTypes.RECEIVE_SWIMLANES_FAILURE]: state => {
    state.epicsSwimlanesFetchFailure = true;
    state.epicsSwimlanesFetchInProgress = false;
  },

  [mutationTypes.RECEIVE_EPICS_SUCCESS]: (state, epics) => {
    state.epics = epics;
    state.issuesByEpicId = epics.reduce((map, epic) => ({
      ...map,
      [epic.id]: epic.issues,
    }), {});
  },

  [mutationTypes.MOVE_ISSUE_EPIC_SWIMLANE]: (state, { listId, epicFromId, epicToId, targetIssueId, oldIndex, newIndex, isFirstChild }) => {
    state.issuesByListId[listId].find(issue => issue.id === targetIssueId).epic = { id: epicToId };
  },

  [mutationTypes.MOVE_ISSUE_EPIC_SWIMLANE_FAILURE]: (state, {listId, targetIssueId, epicFromId}) => {
    state.issuesByListId[listId].find(issue => issue.id === targetIssueId).epic = { id: epicFromId };
  },

  [mutationTypes.RECEIVE_ISSUES_FOR_ALL_LISTS_SUCCESS]: (state, listIssues) => {
    /* eslint-disable no-unused-vars */
    Object.entries(listIssues).forEach(([key, value]) => {
      value.forEach(issue => {
        if (issue.epic?.id && state.issuesByEpicId[issue.epic.id]) {
          const { epicIssueId } = state.issuesByEpicId[issue.epic.id].find(i => i.id === issue.idOriginal);
          issue.updateData({ epicIssueId });
        }
      })
    });

    state.issuesByListId = listIssues;
    state.isLoadingIssues = false;
  },
};
