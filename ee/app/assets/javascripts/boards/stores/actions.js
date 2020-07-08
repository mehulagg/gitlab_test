import axios from 'axios';
import actionsCE from '~/boards/stores/actions';
import boardsStoreEE from './boards_store_ee';
import * as types from './mutation_types';

import createDefaultClient from '~/lib/graphql';
import { BoardType } from '~/boards/constants';
import groupEpicsSwimlanesQuery from '../queries/group_epics_swimlanes.query.graphql';
import projectEpicsSwimlanesQuery from '../queries/project_epics_swimlanes.query.graphql';
import groupEpics from '../queries/group_epics.query.graphql';

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
      return {
        epics: epicGroups.nodes,
        lists: lists.nodes,
      };
    });
};

const fetchEpics = ({ endpoints }) => {
  const { fullPath } = endpoints;

  const query = groupEpics;
  const variables = {
    fullPath,
  };

  return gqlClient
    .query({
      query,
      variables,
    })
    .then(({ data }) => {
      const { group } = data;
      const epics = group?.epics.nodes || [];
      return epics.map(e => ({
        ...e,
        issues: (e?.issues?.nodes || []).map(i => ({
          ...i,
          labels: i.labels?.nodes || [],
          assignees: i.assignees?.nodes || [],
        })),
      }));
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
      Promise.all([fetchEpicsSwimlanes(state), fetchEpics(state)])
        .then(([{ lists }, epics]) => {
          if (lists) {
            dispatch('receiveBoardListsSuccess', lists);
          }

          if (epics) {
            dispatch('receiveEpicsSuccess', epics);
          }
        })
        .catch(() => dispatch('receiveSwimlanesFailure'));
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
};
