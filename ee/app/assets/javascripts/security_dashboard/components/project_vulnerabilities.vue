<script>
import produce from 'immer';
import { GlAlert, GlLoadingIcon, GlIntersectionObserver } from '@gitlab/ui';
import { __ } from '~/locale';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import VulnerabilityList from './vulnerability_list.vue';
import vulnerabilitiesQuery from '../graphql/project_vulnerabilities.graphql';
import securityScannersQuery from '../graphql/project_security_scanners.graphql';
import { VULNERABILITIES_PER_PAGE } from '../store/constants';
import { preparePageInfo } from '../helpers';

export default {
  name: 'ProjectVulnerabilitiesApp',
  components: {
    GlAlert,
    GlLoadingIcon,
    GlIntersectionObserver,
    VulnerabilityList,
  },
  mixins: [glFeatureFlagsMixin()],
  props: {
    projectFullPath: {
      type: String,
      required: true,
    },
    filters: {
      type: Object,
      required: false,
      default: () => ({}),
    },
  },
  data() {
    return {
      pageInfo: {},
      vulnerabilities: [],
      securityScanners: {},
      errorLoadingVulnerabilities: false,
      sortBy: 'severity',
      sortDirection: 'desc',
    };
  },
  apollo: {
    vulnerabilities: {
      query: vulnerabilitiesQuery,
      variables() {
        return {
          fullPath: this.projectFullPath,
          first: VULNERABILITIES_PER_PAGE,
          sort: this.sort,
          ...this.filters,
        };
      },
      update: ({ project }) => project.vulnerabilities.nodes,
      result({ data }) {
        this.pageInfo = preparePageInfo(data?.project?.vulnerabilities?.pageInfo);
      },
      error() {
        this.errorLoadingVulnerabilities = true;
      },
    },
    securityScanners: {
      query: securityScannersQuery,
      variables() {
        return {
          fullPath: this.projectFullPath,
        };
      },
      error() {
        this.securityScanners = {};
      },
      update({ project: { securityScanners = {} } = {} }) {
        const { available = [], enabled = [], pipelineRun = [] } = securityScanners;
        const translateScannerName = scannerName => this.$options.i18n[scannerName] || scannerName;

        return {
          available: available.map(translateScannerName),
          enabled: enabled.map(translateScannerName),
          pipelineRun: pipelineRun.map(translateScannerName),
        };
      },
      skip() {
        return !this.glFeatures.scannerAlerts;
      },
    },
  },
  computed: {
    isLoadingVulnerabilities() {
      return this.$apollo.queries.vulnerabilities.loading;
    },
    isLoadingFirstVulnerabilities() {
      return this.isLoadingVulnerabilities && this.vulnerabilities.length === 0;
    },
    sort() {
      return `${this.sortBy}_${this.sortDirection}`;
    },
  },
  methods: {
    fetchNextPage() {
      if (this.pageInfo.hasNextPage) {
        this.$apollo.queries.vulnerabilities.fetchMore({
          variables: { after: this.pageInfo.endCursor },
          updateQuery: (previousResult, { fetchMoreResult }) => {
            const results = produce(fetchMoreResult, draftData => {
              // eslint-disable-next-line no-param-reassign
              draftData.project.vulnerabilities.nodes = [
                ...previousResult.project.vulnerabilities.nodes,
                ...draftData.project.vulnerabilities.nodes,
              ];
            });
            return results;
          },
        });
      }
    },
    handleSortChange({ sortBy, sortDesc }) {
      this.sortDirection = sortDesc ? 'desc' : 'asc';
      this.sortBy = sortBy;
    },
  },
  i18n: {
    CONTAINER_SCANNING: __('Container Scanning'),
    COVERAGE_FUZZING: __('Coverage Fuzzing'),
    SECRET_DETECTION: __('Secret Detection'),
    DEPENDENCY_SCANNING: __('Dependency Scanning'),
  },
};
</script>

<template>
  <div>
    <gl-alert v-if="errorLoadingVulnerabilities" :dismissible="false" variant="danger">
      {{
        s__(
          'SecurityReports|Error fetching the vulnerability list. Please check your network connection and try again.',
        )
      }}
    </gl-alert>
    <vulnerability-list
      v-else
      :is-loading="isLoadingFirstVulnerabilities"
      :filters="filters"
      :vulnerabilities="vulnerabilities"
      :security-scanners="securityScanners"
      @sort-changed="handleSortChange"
    />
    <gl-intersection-observer
      v-if="pageInfo.hasNextPage"
      class="text-center"
      @appear="fetchNextPage"
    >
      <gl-loading-icon v-if="isLoadingVulnerabilities" size="md" />
      <span v-else>&nbsp;</span>
    </gl-intersection-observer>
  </div>
</template>
