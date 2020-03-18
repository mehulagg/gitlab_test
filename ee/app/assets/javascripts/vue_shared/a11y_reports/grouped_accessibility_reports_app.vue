<script>
import { mapActions, mapGetters, mapState } from 'vuex';
import { componentNames } from '~/reports/components/issue_body.js';
import ReportSection from '~/reports/components/report_section.vue';
import SummaryRow from '~/reports/components/summary_row.vue';
import IssuesList from '~/reports/components/issues_list.vue';
import createStore from './store';

export default {
  name: 'GroupedTestReportsApp',
  store: createStore(),
  components: {
    ReportSection,
    SummaryRow,
    IssuesList,
  },
  props: {
    endpoint: {
      type: String,
      required: true,
    },
  },
  componentNames,
  computed: {
    ...mapGetters([
      'summaryStatus',
      'groupedSummaryText',
      'hasIssues',
      'shouldRenderIssuesList',
      'reportStatusIcon',
      'reportText',
      'unresolvedIssues',
      'resolvedIssues',
      'newIssues',
    ]),
  },
  created() {
    this.setEndpoint(this.endpoint);

    this.fetchReport();
  },
  methods: {
    ...mapActions(['setEndpoint', 'fetchReport']),
  },
};
</script>
<template>
  <report-section
    :status="summaryStatus"
    :success-text="groupedSummaryText"
    :loading-text="groupedSummaryText"
    :error-text="groupedSummaryText"
    :has-issues="hasIssues"
    class="mr-widget-section grouped-security-reports mr-report"
  >
    <div slot="body" class="mr-widget-grouped-section report-block">
      <summary-row :summary="reportText" :status-icon="reportStatusIcon" />
      <issues-list
        v-if="shouldRenderIssuesList"
        :unresolved-issues="unresolvedIssues"
        :new-issues="newIssues"
        :resolved-issues="resolvedIssues"
        :component="$options.componentNames.TestIssueBody"
        class="report-block-group-list"
      />
    </div>
  </report-section>
</template>
