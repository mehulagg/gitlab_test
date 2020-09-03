import Vue from 'vue';
import { pull } from 'lodash';
import { formatIssue, moveIssueListHelper } from '../boards_util';
import * as mutationTypes from './mutation_types';
import { __ } from '~/locale';

const notImplemented = () => {
  /* eslint-disable-next-line @gitlab/require-i18n-strings */
  throw new Error('Not implemented!');
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

  [mutationTypes.REQUEST_UPDATE_LIST]: () => {
    notImplemented();
  },

  [mutationTypes.RECEIVE_UPDATE_LIST_SUCCESS]: () => {
    notImplemented();
  },

  [mutationTypes.RECEIVE_UPDATE_LIST_ERROR]: () => {
    notImplemented();
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

  [mutationTypes.MOVE_ISSUE]: (state, { originalIssue, fromListId, toListId, moveBeforeId, moveAfterId }) => {
    const fromList = state.boardLists.find(l => l.id === fromListId);
    const toList = state.boardLists.find(l => l.id === toListId);

    const issue =  moveIssueListHelper(originalIssue, fromList, toList);
    Vue.set(state.issues, issue.id, issue);

    Vue.set(state.issuesByListId, fromListId, pull(state.issuesByListId[fromListId], originalIssue.id));
    const toListIssues = state.issuesByListId[toListId];
    let newIndex = 0;
    if (moveBeforeId) {
      console.log('BEFORE');
      newIndex = toListIssues.indexOf(moveBeforeId);
    } else if (moveAfterId) {
      console.log('AFTER');
      newIndex = toListIssues.indexOf(moveAfterId) + 1;
    }
    console.log('NEW INDEX', newIndex);
    toListIssues.splice(newIndex, 0, issue.id);
    Vue.set(state.issuesByListId, toListId, toListIssues);
  },

  [mutationTypes.MOVE_ISSUE_SUCCESS]: (state, { issue }) => {
    Vue.set(state.issues, issue.id, formatIssue(issue));
  },

  [mutationTypes.MOVE_ISSUE_FAILURE]: (state, { originalIssue, fromListId, toListId, moveBeforeId, moveAfterId }) => {
    state.error = __('An error occurred while moving the issue. Please try again.');
    Vue.set(state.issues, originalIssue.id, originalIssue);
    // const fromListIssues = state.issuesByListId[fromListId];
    // fromListIssues.splice(newIndex, 1);
    // Vue.set(state.issuesByListId, fromListId, pull(state.issuesByListId[fromListId], originalIssue.id));

    // Vue.set(state.issuesByListId, toListId, pull(state.issuesByListId[fromListId], originalIssue.id));
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

  [mutationTypes.SET_CURRENT_PAGE]: () => {
    notImplemented();
  },

  [mutationTypes.TOGGLE_EMPTY_STATE]: () => {
    notImplemented();
  },
};
