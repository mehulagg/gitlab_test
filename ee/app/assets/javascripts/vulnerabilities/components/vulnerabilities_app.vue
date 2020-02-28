<script>
// TODO: Handle erors
// TODO: Clean out the crap
// TODO: hook up the pagination component

import { GlAlert, GlButton, GlEmptyState } from '@gitlab/ui';

import VulnerabilityList from 'ee/vulnerabilities/components/vulnerability_list.vue';
import vulnerabilitiesQuery from '../graphql/vulnerabilities.gql';
import Observer from './observer.vue';

export default {
  name: 'VulnerabilitiesApp',
  components: {
    GlAlert,
    GlButton,
    GlEmptyState,
    Observer,
    VulnerabilityList,
  },
  data: () => ({
    pageInfo: {},
    vulnerabilities: [],
  }),
  computed: {
    isLoadingVulnerabilities() {
      return this.$apollo.queries.vulnerabilities.loading;
    },
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
  apollo: {
    vulnerabilities: {
      query: vulnerabilitiesQuery,
      variables() {
        return {
          fullPath: 'twitter/secure-it-reports',
          first: this.$options.PAGE_SIZE,
        };
      },
      update: data => data.project.vulnerabilities.nodes,
      result(res) {
        this.pageInfo = res.data.project.vulnerabilities.pageInfo;
      },
    },
  },
  PAGE_SIZE: 10,
  methods: {
    nextPage() {
      if (this.pageInfo.hasNextPage) {
        this.$apollo.queries.vulnerabilities.fetchMore({
          variables: {
            first: this.$options.PAGE_SIZE,
            after: this.pageInfo.endCursor,
          },
          updateQuery: (prev, { fetchMoreResult }) => {
            const result = { ...fetchMoreResult };
            result.project.vulnerabilities.nodes = [
              ...prev.project.vulnerabilities.nodes,
              ...fetchMoreResult.project.vulnerabilities.nodes,
            ];
            return result;
          },
        });
      }
    },
  },
};
</script>

<template>
  <div>
    <!-- <gl-alert v-if="errorLoadingVulnerabilities" :dismissible="false" variant="danger">
          {{
            s__(
              'Security Dashboard|Error fetching the vulnerability list. Please check your network connection and try again.',
            )
          }}
          this.$apollo.queries.vulnerabilities.loading
        </gl-alert> -->
    <vulnerability-list
      :is-loading="false"
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
    <observer v-if="pageInfo.hasNextPage" class="text-center" @intersect="nextPage">
      <gl-button
        :loading="isLoadingVulnerabilities"
        :disabled="isLoadingVulnerabilities"
        @click="nextPage"
        >{{ __('Load more vulnerabilities') }}</gl-button
      >
    </observer>
  </div>
</template>
