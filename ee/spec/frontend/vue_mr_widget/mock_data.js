import mockData, { mockStore } from 'jest/vue_mr_widget/mock_data';

export default {
  ...mockData,
  vulnerability_feedback_help_path: '/help/user/application_security/index',
  enabled_reports: {
    sast: false,
    container_scanning: false,
    dast: false,
    dependency_scanning: false,
    license_management: false,
    secret_scanning: false,
  },
};

export const headPerformance = [
  {
    subject: '/some/path',
    metrics: [
      {
        name: 'Sitespeed Score',
        value: 85,
      },
    ],
  },
  {
    subject: '/some/other/path',
    metrics: [
      {
        name: 'Total Score',
        value: 79,
        desiredSize: 'larger',
      },
      {
        name: 'Requests',
        value: 3,
        desiredSize: 'smaller',
      },
    ],
  },
  {
    subject: '/yet/another/path',
    metrics: [
      {
        name: 'Sitespeed Score',
        value: 80,
      },
    ],
  },
];

export const basePerformance = [
  {
    subject: '/some/path',
    metrics: [
      {
        name: 'Sitespeed Score',
        value: 84,
      },
    ],
  },
  {
    subject: '/some/other/path',
    metrics: [
      {
        name: 'Total Score',
        value: 80,
        desiredSize: 'larger',
      },
      {
        name: 'Requests',
        value: 4,
        desiredSize: 'smaller',
      },
    ],
  },
];

export const codequalityParsedIssues = [
  {
    name: 'Insecure Dependency',
    fingerprint: 'ca2e59451e98ae60ba2f54e3857c50e5',
    path: 'Gemfile.lock',
    line: 12,
    urlPath: 'foo/Gemfile.lock',
  },
];

export { mockStore };
