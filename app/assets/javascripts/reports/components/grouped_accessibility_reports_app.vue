<script>
import { mapActions, mapGetters, mapState } from 'vuex';
import { s__ } from '~/locale';
import { componentNames } from './issue_body';
import ReportSection from './report_section.vue';
import SummaryRow from './summary_row.vue';
import IssuesList from './issues_list.vue';
import Modal from './modal.vue';
import createStore from '../store';
import { summaryTextBuilder, reportTextBuilder, statusIcon } from '../store/utils';

/*
- Move this file to EE
- Make store based on this file
- This file is used for multiple test reports, we want just a single report
*/

export default {
  name: 'GroupedTestReportsApp',
  store: createStore(),
  components: {
    ReportSection,
    SummaryRow,
    IssuesList,
    Modal,
  },
  props: {
    endpoint: {
      type: String,
      required: true,
    },
  },
  componentNames,
  computed: {
    ...mapState(['reports', 'isLoading', 'hasError', 'summary']),
    ...mapState({
      modalTitle: state => state.modal.title || '',
      modalData: state => state.modal.data || {},
    }),
    ...mapGetters(['summaryStatus']),
    groupedSummaryText() {
      if (this.isLoading) {
        return s__('Reports|Accessibility scanning results are being parsed');
      }

      if (this.hasError) {
        return s__('Reports|Accessibility scanning failed loading results');
      }

      return summaryTextBuilder(() => s__('Reports|Accessibility scanning'), this.summary);
    },
  },
  created() {
    this.setEndpoint(this.endpoint);

    this.fetchReports();
  },
  methods: {
    ...mapActions(['setEndpoint', 'fetchReports']),
    reportText(report) {
      const summary = report.summary || {};
      return reportTextBuilder(report.name, summary);
    },
    getReportIcon(report) {
      return statusIcon(report.status);
    },
    shouldRenderIssuesList(report) {
      return (
        report.existing_warnings.length > 0 ||
        report.new_warnings.length > 0 ||
        report.resolved_warnings.length > 0 ||
        report.existing_errors.length > 0 ||
        report.new_errors.length > 0 ||
        report.resolved_errors.length > 0 ||
        report.existing_notes.length > 0 ||
        report.new_notes.length > 0 ||
        report.resolved_notes.length > 0
      );
    },
    unresolvedIssues(report) {
      return report.existing_warnings.concat(report.existing_errors).concat(report.existing_notes);
    },
    newIssues(report) {
      return report.new_warnings.concat(report.new_errors).concat(report.new_notes);
    },
    resolvedIssues(report) {
      return report.resolved_warnings.concat(report.resolved_errors).concat(report.resolved_notes);
    },
  },
};
</script>
<template>
  <report-section
    :status="summaryStatus"
    :success-text="groupedSummaryText"
    :loading-text="groupedSummaryText"
    :error-text="groupedSummaryText"
    :has-issues="reports.length > 0"
    class="mr-widget-section grouped-security-reports mr-report"
  >
    <div slot="body" class="mr-widget-grouped-section report-block">
      <template v-for="(report, i) in reports">
        <summary-row
          :key="`summary-row-${i}`"
          :summary="reportText(report)"
          :status-icon="getReportIcon(report)"
        />
        <issues-list
          v-if="shouldRenderIssuesList(report)"
          :key="`issues-list-${i}`"
          :unresolved-issues="unresolvedIssues(report)"
          :new-issues="newIssues(report)"
          :resolved-issues="resolvedIssues(report)"
          :component="$options.componentNames.TestIssueBody"
          class="report-block-group-list"
        />
      </template>

      <modal :title="modalTitle" :modal-data="modalData" />
    </div>
  </report-section>
</template>
