import { sortBy } from 'lodash';
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
    state.issuesByEpicId = epics.reduce(
      (map, epic) => ({
        ...map,
        [epic.id]: epic.issues,
      }),
      {},
    );
  },

  [mutationTypes.MOVE_ISSUE_EPIC_SWIMLANE]: (
    state,
    { listId, epicFromId, epicToId, targetIssueId, oldIndex, newIndex },
  ) => {
    const targetIssue = state.issuesByEpicAndListId[epicFromId][listId].find(
      issue => issue.id === targetIssueId,
    );

    // Remove from old position in previous parent
    state.issuesByEpicAndListId[epicFromId][listId].splice(oldIndex, 1);

    // Insert at new position in new parent
    state.issuesByEpicAndListId[epicToId][listId].splice(newIndex, 0, targetIssue);
  },

  [mutationTypes.MOVE_ISSUE_EPIC_SWIMLANE_FAILURE]: (
    state,
    { listId, epicFromId, epicToId, targetIssueId, oldIndex, newIndex },
  ) => {
    const targetIssue = state.issuesByEpicAndListId[epicToId][listId].find(
      issue => issue.id === targetIssueId,
    );

    // Remove from old position in previous parent
    state.issuesByEpicAndListId[epicToId][listId].splice(newIndex, 1);

    // Insert at new position in new parent
    state.issuesByEpicAndListId[epicFromId][listId].splice(oldIndex, 0, targetIssue);
  },

  [mutationTypes.RECEIVE_ISSUES_FOR_ALL_LISTS_SUCCESS]: (state, listIssues) => {
    /* eslint-disable no-unused-vars */
    // Populate epicIssueId on all issues
    Object.entries(listIssues).forEach(([listId, issues]) => {
      issues.forEach(issue => {
        if (issue.epic?.id && state.issuesByEpicId[issue.epic.id]) {
          const { epicIssueId, relativePosition } = state.issuesByEpicId[issue.epic.id].find(
            i => i.id === issue.idOriginal,
          );
          issue.updateData({ epicIssueId, position: relativePosition });
        }
      });
    });

    // Create object of type [epicId]:[listId]:Array(issues)
    const issuesByEpicAndListId = {};
    Object.entries(state.issuesByEpicId).forEach(([epicId]) => {
      issuesByEpicAndListId[epicId] = {};
      Object.entries(listIssues).forEach(([listId, issues]) => {
        issuesByEpicAndListId[epicId][listId] = sortBy(
          [...issues.filter(i => i.epic?.id === epicId)],
          'position',
        );
      });
    });
    // Add issues unassigned to epic
    issuesByEpicAndListId.noEpic = {};
    Object.entries(listIssues).forEach(([listId, issues]) => {
      issuesByEpicAndListId.noEpic[listId] = sortBy(
        [...issues.filter(i => i.epic === null)],
        'position',
      );
    });

    state.issuesByEpicAndListId = issuesByEpicAndListId;

    state.issuesByListId = listIssues;
    state.isLoadingIssues = false;
  },
};
