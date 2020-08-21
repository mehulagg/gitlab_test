<script>
import { GlLoadingIcon } from '@gitlab/ui';
import { fetchPolicies } from '~/lib/graphql';
import getTestSummary from '../../graphql/queries/get_test_report_summary.query.graphql';
import getTestSuiteReport from '../../graphql/queries/get_test_suite_report.query.graphql';
import TestSuiteTable from './test_suite_table.vue';
import TestSummary from './test_summary.vue';
import TestSummaryTable from './test_summary_table.vue';

export default {
  name: 'TestReports',
  components: {
    GlLoadingIcon,
    TestSuiteTable,
    TestSummary,
    TestSummaryTable,
  },
  inject: {
    pipelineIid: {
      default: '',
    },
    pipelineProjectPath: {
      default: '',
    },
    summaryEndpoint: {
      default: '',
    },
    suiteEndpoint: {
      default: '',
    },
  },
  apollo: {
    testReport: {
      fetchPolicy: fetchPolicies.CACHE_AND_NETWORK,
      query: getTestSummary,
      variables() {
        return {
          projectPath: this.pipelineProjectPath,
          iid: this.pipelineIid,
        };
      },
      update: data => data.project.pipeline.testReport,
    },
  },
  data() {
    return {
      testReport: {},
      selectedSuiteIndex: null,
    };
  },
  computed: {
    showSuite() {
      return this.selectedSuiteIndex !== null;
    },
    showTests() {
      const { testSuites } = this.testReports;
      return testSuites.length > 0;
    },
    selectedSuite() {
      if (this.selectedSuiteIndex === null) {
        return {};
      }
      return this.testReport.testSuite[this.selectedSuiteIndex];
    }
  },
  created() {
    this.fetchSummary();
  },
  methods: {
    summaryBackClick() {
      // Clear selected test suite and go back to summary view
      this.selectedSuiteIndex = null;
    },
    summaryTableRowClick(index) {
      // Set the selected test suite so that the view changes
      this.selectedSuiteIndex = index;

      // Fetch test suite when the user clicks to see more details
      // QUESTION: Does this cache and not refetch when clicked on again?
      this.$apollo.addSmartQuery('testSuiteReport', {
        // QUESTION: What does this fetchPolicy do?
        fetchPolicy: fetchPolicies.CACHE_AND_NETWORK,
        query: getTestSuiteReport,
        variables() {
          return {
            projectPath: this.pipelineProjectPath,
            iid: this.pipelineIid,
            buildIds: this.testReport.testSuites[index].buildIds,
          };
        },
        // QUESTION: Am I doing this update function correctly? I want the data to all
        // go in the this.testReport data object
        update: data => data.project.pipeline.testReport.testSuites[index],
      });
    },
    beforeEnterTransition() {
      document.documentElement.style.overflowX = 'hidden';
    },
    afterLeaveTransition() {
      document.documentElement.style.overflowX = '';
    },
  },
};
</script>

<template>
  <div v-if="$apollo.loading">
    <gl-loading-icon size="lg" class="gl-mt-3 js-loading-spinner" />
  </div>

  <div
    v-else-if="showTests"
    ref="container"
    class="tests-detail position-relative js-tests-detail"
  >
    <transition
      name="slide"
      @before-enter="beforeEnterTransition"
      @after-leave="afterLeaveTransition"
    >
      <div v-if="showSuite" key="detail" class="w-100 position-absolute slide-enter-to-element">
        <test-summary :report="selectedSuite" show-back @on-back-click="summaryBackClick" />

        <test-suite-table />
      </div>

      <div v-else key="summary" class="w-100 position-absolute slide-enter-from-element">
        <test-summary :report="testReports" />

        <test-summary-table @row-click="summaryTableRowClick" />
      </div>
    </transition>
  </div>

  <div v-else>
    <div class="row gl-mt-3">
      <div class="col-12">
        <p class="js-no-tests-to-show">{{ s__('TestReports|There are no tests to show.') }}</p>
      </div>
    </div>
  </div>
</template>
