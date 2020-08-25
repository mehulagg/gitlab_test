<script>
import { GlLoadingIcon } from '@gitlab/ui';
import getTestSummary from '../../graphql/queries/get_test_report_summary.query.graphql';
import getTestSuiteReport from '../../graphql/queries/get_test_suite_report.query.graphql';
import TestSuiteTable from './test_suite_table.vue';
import TestSummary from './test_summary.vue';
import TestSummaryTable from './test_summary_table.vue';
import { addIconStatus, formattedTime, sortTestCases } from '../../stores/test_reports/utils';

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
      query: getTestSummary,
      variables() {
        return {
          projectPath: this.pipelineProjectPath,
          iid: this.pipelineIid,
          endpoint: this.summaryEndpoint,
        };
      },
      update(data) {
        return data.testReport;
      },
    },
  },
  data() {
    return {
      testReport: {},
      selectedSuiteIndex: null,
      testSuite: {},
    };
  },
  computed: {
    showSuite() {
      return this.selectedSuiteIndex !== null;
    },
    showTests() {
      const { testSuites = [] } = this.testReport;
      return testSuites.length > 0;
    },
    selectedSuite() {
      if (this.selectedSuiteIndex === null) {
        return {};
      }
      console.log(this.testReport);
      console.log(this.testSuite);
      return this.testSuite;
    },
    suiteTests() {
      if (!this.showSuite) {
        return [];
      }

      const { testCases = [] } = this.selectedSuite || {};
      return testCases.sort(sortTestCases).map(addIconStatus);
    },
    testSuites() {
      if (!this.showTests) {
        return [];
      }
      return this.testReport.testSuites.map(suite => ({
        ...suite,
        formattedTime: formattedTime(suite.total.time)
      }))
    },
  },
  methods: {
    summaryBackClick() {
      // Clear selected test suite and go back to summary view
      this.selectedSuiteIndex = null;
    },
    summaryTableRowClick(index) {
      // Set the selected test suite so that the view changes
      const testSuite = this.testReport.testSuites[index];

      // Fetch test suite when the user clicks to see more details
      // QUESTION: Does this cache and not refetch when clicked on again?
      this.$apollo.addSmartQuery('testSuite', {
        query: getTestSuiteReport,
        variables() {
          return {
            projectPath: this.pipelineProjectPath,
            iid: this.pipelineIid,
            endpoint: this.suiteEndpoint,
            suiteName: testSuite.name,
            suiteIndex: index,
            buildIds: this.testReport.testSuites[index].buildIds,
          };
        },
        update(data) {
          this.selectedSuiteIndex = index;
          return data.testSuites;
        },
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

        <test-suite-table :suite-tests="suiteTests" />
      </div>

      <div v-else key="summary" class="w-100 position-absolute slide-enter-from-element">
        <test-summary :report="testReport" />

        <test-summary-table :test-suites="testSuites" @row-click="summaryTableRowClick" />
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
