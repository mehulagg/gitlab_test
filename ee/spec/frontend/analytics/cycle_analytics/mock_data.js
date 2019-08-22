import { TEST_HOST } from 'helpers/test_constants';

export const group = {
  id: 1,
  name: 'foo',
  path: 'foo',
  avatar_url: `${TEST_HOST}/images/home/nasa.svg`,
};

export const cycleAnalyticsData = {
  summary: [{ value: 0, title: 'New Issues' }, { value: 0, title: 'Deploys' }],
  stats: [
    {
      title: 'Issue',
      name: 'issue',
      legend: 'Related Issues',
      description: 'Time before an issue gets scheduled',
      value: null,
    },
    {
      title: 'Plan',
      name: 'plan',
      legend: 'Related Issues',
      description: 'Time before an issue starts implementation',
      value: null,
    },
    {
      title: 'Code',
      name: 'code',
      legend: 'Related Merge Requests',
      description: 'Time until first merge request',
      value: null,
    },
    {
      title: 'Test',
      name: 'test',
      legend: 'Related Jobs',
      description: 'Total test time for all commits/merges',
      value: null,
    },
    {
      title: 'Review',
      name: 'review',
      legend: 'Related Merged Requests',
      description: 'Time between merge request creation and merge/close',
      value: null,
    },
    {
      title: 'Staging',
      name: 'staging',
      legend: 'Related Deployed Jobs',
      description: 'From merge request merge until deploy to production',
      value: null,
    },
    {
      title: 'Production',
      name: 'production',
      legend: 'Related Issues',
      description: 'From issue creation until deploy to production',
      value: null,
    },
  ],
  permissions: {
    issue: true,
    plan: true,
    code: true,
    test: true,
    review: true,
    staging: true,
    production: true,
  },
};

export const issueStage = {
  component: 'stage-issue-component',
  description: 'Time before an issue gets scheduled',
  emptyStageText:
    'The issue stage shows the time it takes from creating an issue to assigning the issue to a milestone, or add the issue to a list on your Issue Board. Begin creating issues to see data for this stage.',
  isUserAllowed: true,
  legend: 'Related Issues',
  name: 'issue',
  slug: 'issue',
  title: 'Issue',
  value: 'less than a minute',
};

export const issueItems = [
  {
    title: 'This is very annoying',
    author: {
      id: 1,
      name: 'Administrator',
      username: 'root',
      state: 'active',
      avatarUrl:
        'https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon',
      webUrl: 'http://localhost:3001/root',
      statusTooltipHtml: null,
      path: '/root',
    },
    iid: '36',
    totalTime: { seconds: 55 },
    createdAt: '1 day ago',
    url: 'http://localhost:3001/twitter/typeahead-js/issues/36',
  },
  {
    title: 'Wtffyyfyf',
    author: {
      id: 1,
      name: 'Administrator',
      username: 'root',
      state: 'active',
      avatarUrl:
        'https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon',
      webUrl: 'http://localhost:3001/root',
      statusTooltipHtml: null,
      path: '/root',
    },
    iid: '35',
    totalTime: { seconds: 20 },
    createdAt: '1 day ago',
    url: 'http://localhost:3001/twitter/typeahead-js/issues/35',
  },
  {
    title: 'Update readme cos this is a test and we want some test data',
    author: {
      id: 1,
      name: 'Administrator',
      username: 'root',
      state: 'active',
      avatarUrl:
        'https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon',
      webUrl: 'http://localhost:3001/root',
      statusTooltipHtml: null,
      path: '/root',
    },
    iid: '32',
    totalTime: { seconds: 0 },
    createdAt: '23 days ago',
    url: 'http://localhost:3001/twitter/typeahead-js/issues/32',
  },
];

export const planItems = [
  {
    title: 'Update readme cos this is a test and we want some test data',
    author: {
      id: 1,
      name: 'Administrator',
      username: 'root',
      state: 'active',
      avatarUrl:
        'https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon',
      webUrl: 'http://localhost:3001/root',
      statusTooltipHtml: null,
      path: '/root',
    },
    iid: '32',
    totalTime: { days: 22, hours: 5, mins: 37, seconds: 43 },
    createdAt: '23 days ago',
    url: 'http://localhost:3001/twitter/typeahead-js/issues/32',
  },
];

export const reviewItems = [
  {
    title: 'Resolve "arargagargaga"',
    author: {
      id: 1,
      name: 'Administrator',
      username: 'root',
      state: 'active',
      avatarUrl:
        'https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon',
      webUrl: 'http://localhost:3001/root',
      statusTooltipHtml: null,
      path: '/root',
    },
    iid: '14',
    totalTime: { mins: 6, seconds: 34 },
    createdAt: '1 day ago',
    url: 'http://localhost:3001/twitter/typeahead-js/merge_requests/14',
    state: 'merged',
  },
  {
    title: 'Resolve "Give me some damn data already"',
    author: {
      id: 1,
      name: 'Administrator',
      username: 'root',
      state: 'active',
      avatarUrl:
        'https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon',
      webUrl: 'http://localhost:3001/root',
      statusTooltipHtml: null,
      path: '/root',
    },
    iid: '13',
    totalTime: { mins: 5, seconds: 46 },
    createdAt: '1 day ago',
    url: 'http://localhost:3001/twitter/typeahead-js/merge_requests/13',
    state: 'merged',
  },
  {
    title: 'Resolve "Update readme cos this is a test and we want some test data"',
    author: {
      id: 1,
      name: 'Administrator',
      username: 'root',
      state: 'active',
      avatarUrl:
        'https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon',
      webUrl: 'http://localhost:3001/root',
      statusTooltipHtml: null,
      path: '/root',
    },
    iid: '9',
    totalTime: { days: 22, hours: 5, mins: 37, seconds: 36 },
    createdAt: '23 days ago',
    url: 'http://localhost:3001/twitter/typeahead-js/merge_requests/9',
    state: 'merged',
  },
];

export const stageData = { events: [] };
