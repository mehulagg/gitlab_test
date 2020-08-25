import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';
import axios from '~/lib/utils/axios_utils';
import TestReports from './components/test_reports/test_reports.vue';

Vue.use(VueApollo);

const normalizeSummaryData = data => ({
  total: {
    ...data.total,
    __typename: 'Total',
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
      __typename: 'Total',
    },
    buildIds: suite.build_ids,
    __typename: 'TestSuite',
  })),
  __typename: 'TestReport',
});

const normalizeSuiteData = (data, buildIds) => ({
  name: data.name,
  total: {
    time: data.total_time,
    count: data.total_count,
    success: data.success_count,
    failed: data.failed_count,
    skipped: data.skipped_count,
    error: data.error_count,
    __typename: 'Total',
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
  })),
  __typename: 'TestSuite',
});

const createTestReportsApp = () => {
  const el = document.querySelector('#js-pipeline-tests-detail');
  const { pipelineProjectPath, pipelineIid, summaryEndpoint, suiteEndpoint } = el?.dataset || {};

  const defaultClient = createDefaultClient(
    {
      Query: {
        testReport(_, { endpoint }) {
          return axios.get(endpoint).then(({ data }) => normalizeSummaryData(data));
        },
        testSuites(_, { buildIds, endpoint, suiteName, suiteIndex }) {
          console.log(suiteIndex);
          // Replacing `/:suite_name.json` with the name of the suite. Including the extra characters
          // to ensure that we replace exactly the template part of the URL string
          const actualEndpoint = endpoint.replace(
            '/:suite_name.json',
            `/${encodeURIComponent(suiteName)}.json`,
          );
          return axios.get(actualEndpoint, { params: { build_ids: buildIds } })
            .then(({ data }) => normalizeSuiteData(data, buildIds));
        },
      },
    },
  );

  const apolloProvider = new VueApollo({
    defaultClient,
  });

  // eslint-disable-next-line no-new
  new Vue({
    el,
    components: {
      TestReports,
    },
    apolloProvider,
    provide: {
      pipelineIid,
      pipelineProjectPath,
      summaryEndpoint,
      suiteEndpoint,
    },
    render(createElement) {
      return createElement('test-reports');
    },
  });
};

export default createTestReportsApp;
