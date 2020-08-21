import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';
import axios from '~/lib/utils/axios_utils';
import TestReports from './components/test_reports/test_reports.vue';
import TestReportSummaryQuery from './graphql/queries/get_test_report_summary.query.graphql';
import TestSuiteReportQuery from './graphql/queries/get_test_suite_report.query.graphql';

Vue.use(VueApollo);

const normalizeTestReportSummary = data => ({
  total: data.total,
  testSuites: data.test_suites.map(suite => ({
    name: suite.name,
    total: {
      time: suite.total_time,
      count: suite.total_count,
      success: suite.total_success,
      failed: suite.total_failed,
      skipped: suite.total_skipped,
      error: suite.total_error,
    },
    buildIds: suite.build_ids,
    __typename: 'TestSuite',
  })),
  __typename: 'TestReport',
});

const fetchSummary = (client, endpoint) => {
  return axios.get(endpoint).then(({ data }) => {
    const { project: { pipeline: { testReport } } } = client.readQuery({ query: TestReportSummaryQuery });
    const newTestReport = {
      ...testReport,
      ...normalizeTestReportSummary(data),
    };
    const result = {
      project: {
        pipeline: {
          testReport: newTestReport,
        }
      }
    };

    client.writeQuery({
      query: TestReportSummaryQuery,
      data: result,
    });

    return result;
  })
};

const normalizeTestSuite = data => ({
  suiteError: data.suiteError,
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

const fetchSuite = (client, endpoint, suiteName, suiteIndex, buildIds) => {
  // Replacing `/:suite_name.json` with the name of the suite. Including the extra characters
  // to ensure that we replace exactly the template part of the URL string
  const suiteEndpoint = endpoint?.replace(
    '/:suite_name.json',
    `/${encodeURIComponent(suiteName)}.json`,
  );

 return axios.get(suiteEndpoint, { params: { build_ids: buildIds } })
    .then(({ data }) => {
      const { project: { pipeline: { testReport } } } = client.readQuery({ query: TestSuiteReportQuery });
      const newTestSuites = [...testReport.testSuites];
      newTestSuites[suiteIndex] = normalizeTestSuite(data);
      const result = {
        project: {
          pipeline: {
            testReport: {
              ...testReport,
              testSuites: newTestSuites,
            }
          }
        }
      };

      client.writeQuery({
        query: TestSuiteReportQuery,
        data: result,
      });

      return result;
    });
};

const createTestReportsApp = () => {
  const el = document.querySelector('#js-pipeline-tests-detail');
  const { pipelineProjectPath, pipelineIid, summaryEndpoint, suiteEndpoint } = el?.dataset || {};

  const defaultClient = createDefaultClient(
    {
      Query: {
        get_test_report_summary(_, { endpoint }) {
          console.log('get_test_report_summary');
          return fetchSummary(defaultClient, endpoint);
        },
        getTestReportSummary(_, { endpoint }) {
          console.log('getTestReportSummary');
          return fetchSummary(defaultClient, endpoint);
        },
        testReport(_, { endpoint }) {
          console.log('testReport');
          return fetchSummary(defaultClient, endpoint);
        },
        getTestSummary(_, { endpoint }) {
          console.log('getTestSummary');
          return fetchSummary(defaultClient, endpoint);
        },
        test_report(_, { endpoint }) {
          console.log('test_report');
          return fetchSummary(defaultClient, endpoint);
        },
        testSuiteReport(_, { endpoint, suiteName, suiteIndex, buildIds }) {
          return fetchSuite(defaultClient, endpoint, suiteName, suiteIndex, buildIds);
        },
      },
      TestReports: {
        testReport: () => {
          console.log('testReport');
          return fetchSummary(defaultClient, summaryEndpoint);
        },
      }
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
