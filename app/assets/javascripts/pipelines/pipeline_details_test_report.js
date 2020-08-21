import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';
import TestReports from './components/test_reports/test_reports.vue';

Vue.use(VueApollo);

const apolloProvider = new VueApollo({
  defaultClient: createDefaultClient(),
});

const createTestReportsApp = () => {
  const el = document.querySelector('#js-pipeline-tests-detail');
  const { pipelineProjectPath, pipelineIid, summaryEndpoint, suiteEndpoint } = el?.dataset || {};

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
