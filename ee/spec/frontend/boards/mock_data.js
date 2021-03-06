import Vue from 'vue';
import List from '~/boards/models/list';

export const mockLists = [
  {
    id: 'gid://gitlab/List/1',
    title: 'Backlog',
    position: null,
    listType: 'backlog',
    collapsed: false,
    label: null,
    maxIssueCount: 0,
    assignee: null,
    milestone: null,
    preset: true,
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
    maxIssueCount: 0,
    assignee: null,
    milestone: null,
    preset: false,
  },
];

export const mockListsWithModel = mockLists.map(listMock =>
  Vue.observable(new List({ ...listMock, doNotFetchIssues: true })),
);

const defaultDescendantCounts = {
  openedIssues: 0,
  closedIssues: 0,
};

const assignees = [
  {
    id: 'gid://gitlab/User/2',
    username: 'angelina.herman',
    name: 'Bernardina Bosco',
    avatar: 'https://www.gravatar.com/avatar/eb7b664b13a30ad9f9ba4b61d7075470?s=80&d=identicon',
    webUrl: 'http://127.0.0.1:3000/angelina.herman',
  },
];

const labels = [
  {
    id: 'gid://gitlab/GroupLabel/5',
    title: 'Cosync',
    color: '#34ebec',
    description: null,
  },
];

export const mockIssue = {
  id: 'gid://gitlab/Issue/436',
  iid: 27,
  title: 'Issue 1',
  referencePath: '#27',
  dueDate: null,
  timeEstimate: 0,
  weight: null,
  confidential: false,
  path: '/gitlab-org/gitlab-test/-/issues/27',
  assignees,
  labels,
  epic: {
    id: 'gid://gitlab/Epic/41',
  },
};

export const mockIssue2 = {
  id: 'gid://gitlab/Issue/437',
  iid: 28,
  title: 'Issue 2',
  referencePath: '#28',
  dueDate: null,
  timeEstimate: 0,
  weight: null,
  confidential: false,
  path: '/gitlab-org/gitlab-test/-/issues/28',
  assignees,
  labels,
  epic: {
    id: 'gid://gitlab/Epic/40',
  },
};

export const mockIssue3 = {
  id: 'gid://gitlab/Issue/438',
  iid: 29,
  title: 'Issue 3',
  referencePath: '#29',
  dueDate: null,
  timeEstimate: 0,
  weight: null,
  confidential: false,
  path: '/gitlab-org/gitlab-test/-/issues/28',
  assignees,
  labels,
  epic: null,
};

export const mockIssue4 = {
  id: 'gid://gitlab/Issue/439',
  iid: 30,
  title: 'Issue 4',
  referencePath: '#30',
  dueDate: null,
  timeEstimate: 0,
  weight: null,
  confidential: false,
  path: '/gitlab-org/gitlab-test/-/issues/28',
  assignees,
  labels,
  epic: null,
};

export const mockIssues = [mockIssue, mockIssue2];

export const mockEpic = {
  id: 'gid://gitlab/Epic/41',
  iid: 1,
  title: 'Epic title',
  state: 'opened',
  webUrl: '/groups/gitlab-org/-/epics/1',
  descendantCounts: {
    openedIssues: 3,
    closedIssues: 2,
  },
  issues: [mockIssue],
};

export const mockEpics = [
  {
    id: 'gid://gitlab/Epic/41',
    iid: 2,
    description: null,
    title: 'Another marketing',
    group_id: 56,
    group_name: 'Marketing',
    group_full_name: 'Gitlab Org / Marketing',
    start_date: '2017-12-26',
    end_date: '2018-03-10',
    web_url: '/groups/gitlab-org/marketing/-/epics/2',
    descendantCounts: defaultDescendantCounts,
    hasParent: true,
    parent: {
      id: '40',
    },
  },
  {
    id: 'gid://gitlab/Epic/40',
    iid: 1,
    description: null,
    title: 'Marketing epic',
    group_id: 56,
    group_name: 'Marketing',
    group_full_name: 'Gitlab Org / Marketing',
    start_date: '2017-12-25',
    end_date: '2018-03-09',
    web_url: '/groups/gitlab-org/marketing/-/epics/1',
    descendantCounts: defaultDescendantCounts,
    hasParent: false,
  },
  {
    id: 'gid://gitlab/Epic/39',
    iid: 12,
    description: null,
    title: 'Epic with end in first timeframe month',
    group_id: 2,
    group_name: 'Gitlab Org',
    group_full_name: 'Gitlab Org',
    start_date: '2017-04-02',
    end_date: '2017-11-30',
    web_url: '/groups/gitlab-org/-/epics/12',
    descendantCounts: defaultDescendantCounts,
    hasParent: false,
  },
  {
    id: 'gid://gitlab/Epic/38',
    iid: 11,
    description: null,
    title: 'Epic with end date out of range',
    group_id: 2,
    group_name: 'Gitlab Org',
    group_full_name: 'Gitlab Org',
    start_date: '2018-01-15',
    end_date: '2020-01-03',
    web_url: '/groups/gitlab-org/-/epics/11',
    descendantCounts: defaultDescendantCounts,
    hasParent: false,
  },
  {
    id: 'gid://gitlab/Epic/37',
    iid: 10,
    description: null,
    title: 'Epic with timeline in same month',
    group_id: 2,
    group_name: 'Gitlab Org',
    group_full_name: 'Gitlab Org',
    start_date: '2018-01-01',
    end_date: '2018-01-31',
    web_url: '/groups/gitlab-org/-/epics/10',
    descendantCounts: defaultDescendantCounts,
    hasParent: false,
  },
];

export const mockIssuesByListId = {
  'gid://gitlab/List/1': [mockIssue.id, mockIssue3.id, mockIssue4.id],
  'gid://gitlab/List/2': mockIssues.map(({ id }) => id),
};

export const issues = {
  [mockIssue.id]: mockIssue,
  [mockIssue2.id]: mockIssue2,
  [mockIssue3.id]: mockIssue3,
  [mockIssue4.id]: mockIssue4,
};
