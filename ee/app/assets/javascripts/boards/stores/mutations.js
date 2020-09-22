import Vue from 'vue';
import { union } from 'lodash';
import mutationsCE from '~/boards/stores/mutations';
import { s__ } from '~/locale';
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

  [mutationTypes.REQUEST_ISSUES_FOR_EPIC]: (state, epicId) => {
    Vue.set(state.epicsFlags, epicId, { isLoading: true });
  },

  [mutationTypes.RECEIVE_ISSUES_FOR_EPIC_SUCCESS]: (state, { listData, issues, epicId }) => {
    Object.entries(listData).forEach(([listId, list]) => {
      Vue.set(state.issuesByListId, listId, union(state.issuesByListId[listId] || [], list));
    });

    Vue.set(state, 'issues', { ...state.issues, ...issues });
    Vue.set(state.epicsFlags, epicId, { isLoading: false });
  },

  [mutationTypes.RECEIVE_ISSUES_FOR_EPIC_FAILURE]: (state, epicId) => {
    state.error = s__('Boards|An error occurred while fetching issues. Please reload the page.');
    Vue.set(state.epicsFlags, epicId, { isLoading: false });
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
    state.error = s__(
      'Boards|An error occurred while fetching the board swimlanes. Please reload the page.',
    );
    state.epicsSwimlanesFetchInProgress = false;
  },

  [mutationTypes.RECEIVE_EPICS_SUCCESS]: (state, epics) => {
    state.epics = epics;
  },
};
