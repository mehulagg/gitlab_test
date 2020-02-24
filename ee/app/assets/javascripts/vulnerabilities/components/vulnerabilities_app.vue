<script>
import { mapActions, mapState } from 'vuex';
import { GlAlert, GlEmptyState, GlPagination } from '@gitlab/ui';

import VulnerabilityList from 'ee/vulnerabilities/components/vulnerability_list.vue';

export default {
  name: 'VulnerabilitiesApp',
  components: {
    GlAlert,
    GlEmptyState,
    GlPagination,
    VulnerabilityList,
  },
  props: {
    vulnerabilitiesEndpoint: {
      type: String,
      required: true,
    },
    dashboardDocumentation: {
      type: String,
      required: true,
    },
    emptyStateSvgPath: {
      type: String,
      required: true,
    },
  },
  computed: {
    ...mapState('vulnerabilities', [
      'errorLoadingVulnerabilities',
      'isLoadingVulnerabilities',
      'pageInfo',
      'vulnerabilities',
    ]),
    ...mapState('filters', ['activeFilters']),
  },
  created() {
    this.setVulnerabilitiesEndpoint(this.vulnerabilitiesEndpoint);
    this.fetchVulnerabilities();
  },
  methods: {
    ...mapActions('vulnerabilities', ['setVulnerabilitiesEndpoint', 'fetchVulnerabilities']),
    fetchPage(page) {
      this.fetchVulnerabilities({ ...this.activeFilters, page });
    },
  },
};
</script>

<template>
  <div>
    <gl-alert v-if="errorLoadingVulnerabilities" :dismissible="false" variant="danger">
      {{
        s__(
          'Security Dashboard|Error fetching the vulnerability list. Please check your network connection and try again.',
        )
      }}
    </gl-alert>
    <vulnerability-list
      v-else
      :is-loading="isLoadingVulnerabilities"
      :dashboard-documentation="dashboardDocumentation"
      :empty-state-svg-path="emptyStateSvgPath"
      :vulnerabilities="vulnerabilities"
    >
      <template #emptyState>
        <gl-empty-state
          :title="s__(`No vulnerabilities found for this project`)"
          :svg-path="emptyStateSvgPath"
          :description="
            s__(
              `While it's rare to have no vulnerabilities for your project, it can happen. In any event, we ask that you double check your settings to make sure you've set up your dashboard correctly.`,
            )
          "
          :primary-button-link="dashboardDocumentation"
          :primary-button-text="s__('Security Reports|Learn more about setting up your dashboard')"
        />
      </template>
    </vulnerability-list>
    <gl-pagination
      class="justify-content-center prepend-top-default"
      :per-page="pageInfo.perPage"
      :total-items="pageInfo.total"
      :value="pageInfo.page"
      @input="fetchPage"
    />
  </div>
</template>
