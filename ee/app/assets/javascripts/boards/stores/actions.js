import axios from 'axios';
import { sortBy } from 'lodash';
import flash from '~/flash';
import { __ } from '~/locale';
import boardsStore from '~/boards/stores/boards_store';
import actionsCE from '~/boards/stores/actions';
import boardsStoreEE from './boards_store_ee';
import * as types from './mutation_types';

import createDefaultClient from '~/lib/graphql';
import { BoardType } from '~/boards/constants';
import groupEpicsSwimlanesQuery from '../queries/group_epics_swimlanes.query.graphql';
import projectEpicsSwimlanesQuery from '../queries/project_epics_swimlanes.query.graphql';
import epicChildReorderQuery from '../../related_items_tree/queries/epicChildReorder.mutation.graphql'

const notImplemented = () => {
  /* eslint-disable-next-line @gitlab/require-i18n-strings */
  throw new Error('Not implemented!');
};

const gqlClient = createDefaultClient();

const fetchEpicsSwimlanes = ({ endpoints, boardType }) => {
  const { fullPath, boardId } = endpoints;

  const query =
    boardType === BoardType.group ? groupEpicsSwimlanesQuery : projectEpicsSwimlanesQuery;

  const variables = {
    fullPath,
    boardId: `gid://gitlab/Board/${boardId}`,
  };

  return gqlClient
    .query({
      query,
      variables,
    })
    .then(({ data }) => {
      const { epicGroups, lists } = data[boardType]?.board;
      const epics = epicGroups.nodes.map(e => ({
        ...e,
        issues: (e?.issues?.nodes || []).map(i => ({
          ...i,
          labels: i.labels?.nodes || [],
          assignees: i.assignees?.nodes || [],
        })),
      }));
      return {
        epics,
        lists: lists.nodes,
      };
    });
};

export default {
  ...actionsCE,

  setShowLabels({ commit }, val) {
    commit(types.SET_SHOW_LABELS, val);
  },

  setActiveListId({ commit }, listId) {
    commit(types.SET_ACTIVE_LIST_ID, listId);
  },
  updateListWipLimit({ state }, { maxIssueCount }) {
    const { activeListId } = state;

    return axios.put(`${boardsStoreEE.store.state.endpoints.listsEndpoint}/${activeListId}`, {
      list: {
        max_issue_count: maxIssueCount,
      },
    });
  },

  fetchAllBoards: () => {
    notImplemented();
  },

  fetchRecentBoards: () => {
    notImplemented();
  },

  createBoard: () => {
    notImplemented();
  },

  deleteBoard: () => {
    notImplemented();
  },

  updateIssueWeight: () => {
    notImplemented();
  },

  togglePromotionState: () => {
    notImplemented();
  },

  toggleEpicSwimlanes: ({ state, commit, dispatch }) => {
    commit(types.TOGGLE_EPICS_SWIMLANES);

    if (state.isShowingEpicsSwimlanes) {
      fetchEpicsSwimlanes(state)
        .then(({ lists, epics }) => {
          if (lists) {
            let boardLists = lists.map(list =>
              boardsStore.updateListPosition({ ...list, doNotFetchIssues: true }),
            );
            boardLists = sortBy([...boardLists], 'position');
            dispatch('receiveBoardListsSuccess', boardLists);
          }

          if (epics) {
            dispatch('receiveEpicsSuccess', epics);
          }
        })
        .catch((e) => {
          console.log('ERROR', e);
          dispatch('receiveSwimlanesFailure')
        });
    }
  },

  receiveBoardListsSuccess: ({ commit }, swimlanes) => {
    commit(types.RECEIVE_BOARD_LISTS_SUCCESS, swimlanes);
  },

  receiveSwimlanesFailure: ({ commit }) => {
    commit(types.RECEIVE_SWIMLANES_FAILURE);
  },

  receiveEpicsSuccess: ({ commit }, swimlanes) => {
    commit(types.RECEIVE_EPICS_SUCCESS, swimlanes);
  },

  moveIssueEpicSwimlane: ({ commit, state }, { listId, epicFromId, epicToId, targetIssueId, epicIssueId, oldIndex, newIndex }) => {
    let adjacentItem;
    let adjacentReferenceId;
    let relativePosition = 'after';

    let isFirstChild = false;
    const newParentChildren = state.issuesByListId[listId].filter(i => i.epic?.id === epicToId);

    if (newParentChildren?.length > 0) {
      adjacentItem = newParentChildren[newIndex];
      if (!adjacentItem) {
        adjacentItem = newParentChildren[newParentChildren.length - 1];
        relativePosition = 'before';
      }
      adjacentReferenceId = adjacentItem.epicIssueId;
    } else {
      isFirstChild = true;
      relativePosition = 'before';
    }

    commit(types.MOVE_ISSUE_EPIC_SWIMLANE, {
      listId,
      epicFromId,
      epicToId,
      targetIssueId,
      oldIndex,
      newIndex,
      isFirstChild,
    });

    return gqlClient
      .mutate({
        mutation: epicChildReorderQuery,
        variables: {
          epicTreeReorderInput: {
            baseEpicId: epicFromId,
            moved: {
              id: epicIssueId,
              adjacentReferenceId,
              relativePosition,
              newParentId: epicToId,
            },
          },
        },
      })
      .then(({ data }) => {
        // Mutation was unsuccessful;
        // revert to original epic
        if (data.epicTreeReorder.errors.length) {
          commit(types.MOVE_ISSUE_EPIC_SWIMLANE_FAILURE, {
            listId,
            epicFromId,
            targetIssueId,
          });
          flash(__('Something went wrong while moving issue.'));
        }
      })
      .catch(() => {
        // Mutation was unsuccessful;
        // revert to original epic
        commit(types.MOVE_ISSUE_EPIC_SWIMLANE_FAILURE, {
          listId,
          epicFromId,
          targetIssueId,
        });
        flash(__('Something went wrong while moving issue.'));
      });
  },
};
