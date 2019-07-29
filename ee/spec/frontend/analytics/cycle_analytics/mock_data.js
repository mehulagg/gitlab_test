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

export const stageData = { events: [] };
