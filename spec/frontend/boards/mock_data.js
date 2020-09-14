/* global ListIssue */
/* global List */

import Vue from 'vue';
import '~/boards/models/list';
import '~/boards/models/issue';
import boardsStore from '~/boards/stores/boards_store';

export const boardObj = {
  id: 1,
  name: 'test',
  milestone_id: null,
};

export const listObj = {
  id: 300,
  position: 0,
  title: 'Test',
  list_type: 'label',
  weight: 3,
  label: {
    id: 5000,
    title: 'Test',
    color: '#ff0000',
    description: 'testing;',
    textColor: 'white',
  },
};

export const listObjDuplicate = {
  id: listObj.id,
  position: 1,
  title: 'Test',
  list_type: 'label',
  weight: 3,
  label: {
    id: listObj.label.id,
    title: 'Test',
    color: '#ff0000',
    description: 'testing;',
  },
};

export const mockAssigneesList = [
  {
    id: 2,
    name: 'Terrell Graham',
    username: 'monserrate.gleichner',
    state: 'active',
    avatar_url: 'https://www.gravatar.com/avatar/598fd02741ac58b88854a99d16704309?s=80&d=identicon',
    web_url: 'http://127.0.0.1:3001/monserrate.gleichner',
    path: '/monserrate.gleichner',
  },
  {
    id: 12,
    name: 'Susy Johnson',
    username: 'tana_harvey',
    state: 'active',
    avatar_url: 'https://www.gravatar.com/avatar/e021a7b0f3e4ae53b5068d487e68c031?s=80&d=identicon',
    web_url: 'http://127.0.0.1:3001/tana_harvey',
    path: '/tana_harvey',
  },
  {
    id: 20,
    name: 'Conchita Eichmann',
    username: 'juliana_gulgowski',
    state: 'active',
    avatar_url: 'https://www.gravatar.com/avatar/c43c506cb6fd7b37017d3b54b94aa937?s=80&d=identicon',
    web_url: 'http://127.0.0.1:3001/juliana_gulgowski',
    path: '/juliana_gulgowski',
  },
  {
    id: 6,
    name: 'Bryce Turcotte',
    username: 'melynda',
    state: 'active',
    avatar_url: 'https://www.gravatar.com/avatar/cc2518f2c6f19f8fac49e1a5ee092a9b?s=80&d=identicon',
    web_url: 'http://127.0.0.1:3001/melynda',
    path: '/melynda',
  },
  {
    id: 1,
    name: 'Administrator',
    username: 'root',
    state: 'active',
    avatar_url: 'https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon',
    web_url: 'http://127.0.0.1:3001/root',
    path: '/root',
  },
];

export const mockMilestone = {
  id: 1,
  state: 'active',
  title: 'Milestone title',
  description: 'Harum corporis aut consequatur quae dolorem error sequi quia.',
  start_date: '2018-01-01',
  due_date: '2019-12-31',
};

export const rawIssue = {
  title: 'Testing',
  id: 'gid://gitlab/Issue/1',
  iid: 1,
  confidential: false,
  referencePath: 'gitlab-org/gitlab-test#1',
  labels: {
    nodes: [
      {
        id: 1,
        title: 'test',
        color: 'red',
        description: 'testing',
      },
    ],
  },
  assignees: {
    nodes: [
      {
        id: 1,
        name: 'name',
        username: 'username',
        avatar_url: 'http://avatar_url',
      },
    ],
  },
};

export const mockIssue = {
  title: 'Testing',
  id: 1,
  iid: 1,
  confidential: false,
  referencePath: 'gitlab-org/gitlab-test#1',
  labels: [
    {
      id: 1,
      title: 'test',
      color: 'red',
      description: 'testing',
    },
  ],
  assignees: [
    {
      id: 1,
      name: 'name',
      username: 'username',
      avatar_url: 'http://avatar_url',
    },
  ],
};

export const mockIssueWithModel = new ListIssue(mockIssue);

export const mockIssue2 = {
  title: 'Planning',
  id: 2,
  iid: 2,
  confidential: false,
  referencePath: 'gitlab-org/gitlab-test#2',
  labels: [
    {
      id: 1,
      title: 'plan',
      color: 'blue',
      description: 'planning',
    },
  ],
  assignees: [
    {
      id: 1,
      name: 'name',
      username: 'username',
      avatar_url: 'http://avatar_url',
    },
  ],
};

export const mockIssue2WithModel = new ListIssue(mockIssue2);

export const BoardsMockData = {
  GET: {
    '/test/-/boards/1/lists/300/issues?id=300&page=1': {
      issues: [
        {
          title: 'Testing',
          id: 1,
          iid: 1,
          confidential: false,
          labels: [],
          assignees: [],
        },
      ],
    },
    '/test/issue-boards/-/milestones.json': [
      {
        id: 1,
        title: 'test',
      },
    ],
  },
  POST: {
    '/test/-/boards/1/lists': listObj,
  },
  PUT: {
    '/test/issue-boards/-/board/1/lists{/id}': {},
  },
  DELETE: {
    '/test/issue-boards/-/board/1/lists{/id}': {},
  },
};

export const boardsMockInterceptor = config => {
  const body = BoardsMockData[config.method.toUpperCase()][config.url];
  return [200, body];
};

export const setMockEndpoints = (opts = {}) => {
  const boardsEndpoint = opts.boardsEndpoint || '/test/issue-boards/-/boards.json';
  const listsEndpoint = opts.listsEndpoint || '/test/-/boards/1/lists';
  const bulkUpdatePath = opts.bulkUpdatePath || '';
  const boardId = opts.boardId || '1';

  boardsStore.setEndpoints({
    boardsEndpoint,
    listsEndpoint,
    bulkUpdatePath,
    boardId,
  });
};

export const mockLists = [
  {
    id: 'gid://gitlab/List/1',
    title: 'Backlog',
    position: null,
    listType: 'backlog',
    collapsed: false,
    label: null,
    assignee: null,
    milestone: null,
  },
  {
    id: 'gid://gitlab/List/2',
    title: 'To Do',
    position: 0,
    listType: 'label',
    collapsed: false,
    label: {
      id: 'gid://gitlab/GroupLabel/121',
      title: 'To Do',
      color: '#F0AD4E',
      textColor: '#FFFFFF',
      description: null,
    },
    assignee: null,
    milestone: null,
  },
];

export const mockListsWithModel = mockLists.map(listMock =>
  Vue.observable(new List({ ...listMock, doNotFetchIssues: true })),
);
