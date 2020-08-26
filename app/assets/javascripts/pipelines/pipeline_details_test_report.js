import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';
import axios from '~/lib/utils/axios_utils';
import TestReports from './components/test_reports/test_reports.vue';
import { normalizeSummaryData, normalizeSuiteData } from './components/test_reports/utils';

Vue.use(VueApollo);

const createTestReportsApp = () => {
  const el = document.querySelector('#js-pipeline-tests-detail');
  const { summaryEndpoint, suiteEndpoint } = el?.dataset || {};

  const defaultClient = createDefaultClient(
    {
      Query: {
        testReport(_, { endpoint }) {
          return axios.get(endpoint).then(({ data }) => normalizeSummaryData(data));
        },
        testSuites(_, { buildIds, endpoint, suiteName }) {
          // Replacing `/:suite_name.json` with the name of the suite. Including the extra characters
          // to ensure that we replace exactly the template part of the URL string
          const actualEndpoint = endpoint.replace(
            '/:suite_name.json',
            `/${encodeURIComponent(suiteName)}.json`,
          );
          // QUESTION: How do I get this data inside of the test report list of test suites?
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
      summaryEndpoint,
      suiteEndpoint,
    },
    render(createElement) {
      return createElement('test-reports');
    },
  });
};

export default createTestReportsApp;
