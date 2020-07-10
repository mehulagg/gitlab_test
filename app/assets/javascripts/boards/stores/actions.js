import * as types from './mutation_types';

import ListIssue from 'ee_else_ce/boards/models/issue';
import createDefaultClient from '~/lib/graphql';
import { BoardType } from '~/boards/constants';
import groupListsIssuesQuery from '../queries/group_lists_issues.graphql';
// import projectEpicsSwimlanesQuery from '../queries/project_epics_swimlanes.query.graphql';

const gqlClient = createDefaultClient();

const notImplemented = () => {
  /* eslint-disable-next-line @gitlab/require-i18n-strings */
  throw new Error('Not implemented!');
};

export default {
  setInitialBoardData: ({ commit }, data) => {
    commit(types.SET_INITIAL_BOARD_DATA, data);
  },

  fetchLists: () => {
    notImplemented();
  },

  generateDefaultLists: () => {
    notImplemented();
  },

  createList: () => {
    notImplemented();
  },

  updateList: () => {
    notImplemented();
  },

  deleteList: () => {
    notImplemented();
  },

  fetchIssuesForList: () => {
    notImplemented();
  },

  fetchIssuesForAllLists: ({ state, commit }) => {
    const { endpoints, boardType } = state;
    const { fullPath, boardId } = endpoints;

    const query = boardType === BoardType.group ? groupListsIssuesQuery : groupListsIssuesQuery;

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
        const { lists } = data[boardType]?.board;
        const listIssues = lists.nodes.reduce((map, list) => {
          return {
            ...map,
            [list.id]: list.issues.nodes.map(
              i =>
                new ListIssue({
                  ...i,
                  id: Number(i.id.match(/\d+$/)[0]),
                  labels: i.labels?.nodes || [],
                  assignees: i.assignees?.nodes || [],
                }),
            ),
          };
        }, {});
        commit(types.RECEIVE_ISSUES_FOR_ALL_LISTS_SUCCESS, listIssues);
        return listIssues;
      });
  },

  moveIssue: () => {
    notImplemented();
  },

  createNewIssue: () => {
    notImplemented();
  },

  fetchBacklog: () => {
    notImplemented();
  },

  bulkUpdateIssues: () => {
    notImplemented();
  },

  fetchIssue: () => {
    notImplemented();
  },

  toggleIssueSubscription: () => {
    notImplemented();
  },

  showPage: () => {
    notImplemented();
  },

  toggleEmptyState: () => {
    notImplemented();
  },
};
