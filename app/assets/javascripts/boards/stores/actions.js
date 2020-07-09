import * as types from './mutation_types';

import createDefaultClient from '~/lib/graphql';
import { BoardType } from '~/boards/constants';
import groupListIssuesQuery from '../queries/group_list_issues.graphql';
//import projectEpicsSwimlanesQuery from '../queries/project_epics_swimlanes.query.graphql';

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

  fetchIssuesForList: ({ state }, listId) => {
    const { endpoints, boardType } = state;
    const { fullPath, boardId } = endpoints;

    const query =
      boardType === BoardType.group ? groupListIssuesQuery : groupListIssuesQuery;

    const variables = {
      fullPath,
      boardId: `gid://gitlab/Board/${boardId}`,
      listId,
    };

    return gqlClient
      .query({
        query,
        variables,
      })
      .then(({ data }) => {
        const { lists } = data[boardType]?.board;
        const listIssues = lists.nodes.map(l => ({
          issues: (l?.issues?.nodes || []).map(i => ({
            ...i,
            labels: i.labels?.nodes || [],
            assignees: i.assignees?.nodes || [],
          })),
        }));
        console.log('listIssues', listIssues);
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
