import Vue from 'vue';
import { sortBy, pull } from 'lodash';
import { formatIssue, moveIssueListHelper } from '../boards_util';
import * as mutationTypes from './mutation_types';
import { __ } from '~/locale';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';

const notImplemented = () => {
  /* eslint-disable-next-line @gitlab/require-i18n-strings */
  throw new Error('Not implemented!');
};

const removeIssueFromList = (state, listId, issueId) => {
  Vue.set(state.issuesByListId, listId, pull(state.issuesByListId[listId], issueId));
};

const addIssueToList = ({ state, listId, issueId, moveBeforeId, moveAfterId, atIndex }) => {
  const listIssues = state.issuesByListId[listId];
  let newIndex = atIndex || 0;
  if (moveBeforeId) {
    newIndex = listIssues.indexOf(moveBeforeId) + 1;
  } else if (moveAfterId) {
    newIndex = listIssues.indexOf(moveAfterId);
  }
  listIssues.splice(newIndex, 0, issueId);
  Vue.set(state.issuesByListId, listId, listIssues);
};

export default {
  [mutationTypes.SET_INITIAL_BOARD_DATA](state, data) {
    const { boardType, disabled, showPromotion, ...endpoints } = data;
    state.endpoints = endpoints;
    state.boardType = boardType;
    state.disabled = disabled;
    state.showPromotion = showPromotion;
  },

  [mutationTypes.RECEIVE_LISTS]: (state, lists) => {
    state.boardLists = lists;
  },

  [mutationTypes.SET_ACTIVE_ID](state, { id, sidebarType }) {
    state.activeId = id;
    state.sidebarType = sidebarType;
  },

  [mutationTypes.SET_FILTERS](state, filterParams) {
    state.filterParams = filterParams;
  },

  [mutationTypes.CREATE_LIST_FAILURE]: state => {
    state.error = __('An error occurred while creating the list. Please try again.');
  },

  [mutationTypes.REQUEST_ADD_LIST]: () => {
    notImplemented();
  },

  [mutationTypes.RECEIVE_ADD_LIST_SUCCESS]: () => {
    notImplemented();
  },

  [mutationTypes.RECEIVE_ADD_LIST_ERROR]: () => {
    notImplemented();
  },

  [mutationTypes.MOVE_LIST]: (state, { movedList, listAtNewIndex }) => {
    const { boardLists } = state;
    const movedListIndex = state.boardLists.findIndex(l => l.id === movedList.id);
    Vue.set(boardLists, movedListIndex, movedList);
    Vue.set(boardLists, movedListIndex.position + 1, listAtNewIndex);
    Vue.set(state, 'boardLists', sortBy(boardLists, 'position'));
  },

  [mutationTypes.UPDATE_LIST_FAILURE]: (state, backupList) => {
    state.error = __('An error occurred while updating the list. Please try again.');
    Vue.set(state, 'boardLists', backupList);
  },

  [mutationTypes.REQUEST_REMOVE_LIST]: () => {
    notImplemented();
  },

  [mutationTypes.RECEIVE_REMOVE_LIST_SUCCESS]: () => {
    notImplemented();
  },

  [mutationTypes.RECEIVE_REMOVE_LIST_ERROR]: () => {
    notImplemented();
  },

  [mutationTypes.REQUEST_ISSUES_FOR_ALL_LISTS]: state => {
    state.isLoadingIssues = true;
  },

  [mutationTypes.RECEIVE_ISSUES_FOR_ALL_LISTS_SUCCESS]: (state, { listData, issues }) => {
    state.issuesByListId = listData;
    state.issues = issues;
    state.isLoadingIssues = false;
  },

  [mutationTypes.UPDATE_ISSUE_BY_ID]: (state, { issueId, prop, value }) => {
    if (!state.issues[issueId]) {
      /* eslint-disable-next-line @gitlab/require-i18n-strings */
      throw new Error('No issue found.');
    }

    Vue.set(state.issues[issueId], prop, value);
  },

  [mutationTypes.RECEIVE_ISSUES_FOR_ALL_LISTS_FAILURE]: state => {
    state.error = __('An error occurred while fetching the board issues. Please reload the page.');
    state.isLoadingIssues = false;
  },

  [mutationTypes.REQUEST_ADD_ISSUE]: () => {
    notImplemented();
  },

  [mutationTypes.RECEIVE_ADD_ISSUE_SUCCESS]: () => {
    notImplemented();
  },

  [mutationTypes.RECEIVE_ADD_ISSUE_ERROR]: () => {
    notImplemented();
  },

  [mutationTypes.MOVE_ISSUE]: (
    state,
    { originalIssue, fromListId, toListId, moveBeforeId, moveAfterId },
  ) => {
    const fromList = state.boardLists.find(l => l.id === fromListId);
    const toList = state.boardLists.find(l => l.id === toListId);

    const issue = moveIssueListHelper(originalIssue, fromList, toList);
    Vue.set(state.issues, issue.id, issue);

    removeIssueFromList(state, fromListId, issue.id);
    addIssueToList({ state, listId: toListId, issueId: issue.id, moveBeforeId, moveAfterId });
  },

  [mutationTypes.MOVE_ISSUE_SUCCESS]: (state, { issue }) => {
    const issueId = getIdFromGraphQLId(issue.id);
    Vue.set(state.issues, issueId, formatIssue({ ...issue, id: issueId }));
  },

  [mutationTypes.MOVE_ISSUE_FAILURE]: (
    state,
    { originalIssue, fromListId, toListId, originalIndex },
  ) => {
    state.error = __('An error occurred while moving the issue. Please try again.');
    Vue.set(state.issues, originalIssue.id, originalIssue);
    removeIssueFromList(state, toListId, originalIssue.id);
    addIssueToList({
      state,
      listId: fromListId,
      issueId: originalIssue.id,
      atIndex: originalIndex,
    });
  },

  [mutationTypes.REQUEST_UPDATE_ISSUE]: () => {
    notImplemented();
  },

  [mutationTypes.RECEIVE_UPDATE_ISSUE_SUCCESS]: () => {
    notImplemented();
  },

  [mutationTypes.RECEIVE_UPDATE_ISSUE_ERROR]: () => {
    notImplemented();
  },

  [mutationTypes.ADD_ISSUE_TO_LIST]: (state, { list, issue, position }) => {
    const listIssues = state.issuesByListId[list.id];
    listIssues.splice(position, 0, issue.id);
    Vue.set(state.issuesByListId, list.id, listIssues);
    Vue.set(state.issues, issue.id, issue);
  },

  [mutationTypes.ADD_ISSUE_TO_LIST_FAILURE]: (state, { list, issue }) => {
    state.error = __('An error occurred while creating the issue. Please try again.');
    removeIssueFromList(state, list.id, issue.id);
  },

  [mutationTypes.SET_CURRENT_PAGE]: () => {
    notImplemented();
  },

  [mutationTypes.TOGGLE_EMPTY_STATE]: () => {
    notImplemented();
  },
};
