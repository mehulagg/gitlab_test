import { TestStatus } from '~/pipelines/constants';
import { __, sprintf } from '../../../locale';

const sortTestSuiteCases = (a, b) => {
  if (a.status === b.status) {
    return 0;
  }

  switch (b.status) {
    case TestStatus.SUCCESS:
      return -1;
    case TestStatus.FAILED:
      return 1;
    default:
      return 0;
  }
};

export const iconForTestStatus = (status) => {
  switch (status) {
    case 'success':
      return 'status_success_borderless';
    case 'failed':
      return 'status_failed_borderless';
    default:
      return 'status_skipped_borderless';
  }
}

export const formatTime = (seconds = 0) => {
  if (seconds < 1) {
    const milliseconds = seconds * 1000;
    return sprintf(__('%{milliseconds}ms'), { milliseconds: milliseconds.toFixed(2) });
  }
  return sprintf(__('%{seconds}s'), { seconds: seconds.toFixed(2) });
};

export const normalizeSummaryData = data => ({
  total: {
    ...data.total,
    __typename: 'TestTotal',
  },
  testSuites: data.test_suites.map(suite => ({
    name: suite.name,
    total: {
      time: suite.total_time,
      count: suite.total_count,
      success: suite.success_count,
      failed: suite.failed_count,
      skipped: suite.skipped_count,
      error: suite.error_count,
      __typename: 'TestTotal',
    },
    buildIds: suite.build_ids,
    __typename: 'TestSuite',
  })),
  __typename: 'TestReport',
});

export const normalizeSuiteData = (data, buildIds) => ({
  name: data.name,
  total: {
    time: data.total_time,
    count: data.total_count,
    success: data.success_count,
    failed: data.failed_count,
    skipped: data.skipped_count,
    error: data.error_count,
    __typename: 'TestTotal',
  },
  buildIds,
  suiteError: data.suite_error,
  testCases: data.test_cases.map(testCase => ({
    status: testCase.status,
    name: testCase.name,
    classname: testCase.classname,
    executionTime: testCase.execution_time,
    systemOutput: testCase.system_output,
    stackTrace: testCase.stack_trace,
    __typename: 'TestCase',
  })).sort(sortTestSuiteCases),
  __typename: 'TestSuite',
});
