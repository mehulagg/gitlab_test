<script>
// TODO: Handle erors
// TODO: Clean out the crap
// TODO: hook up the pagination component

import { ApolloQuery } from 'vue-apollo';
import { GlAlert, GlEmptyState, GlPagination } from '@gitlab/ui';

import VulnerabilityList from 'ee/vulnerabilities/components/vulnerability_list.vue';
import vulnerabilitiesQuery from '../graphql/vulnerabilities.gql';

export default {
  name: 'VulnerabilitiesApp',
  components: {
    ApolloQuery,
    GlAlert,
    GlEmptyState,
    GlPagination,
    VulnerabilityList,
  },
  data: () => ({
    pageInfo: {},
    vulnerabilities: [],
  }),
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
          updateQuery: (_, { fetchMoreResult }) => fetchMoreResult,
        });
      }
    },
    previousPage() {
      this.$apollo.queries.vulnerabilities.fetchMore({
        variables: {
          last: this.$options.PAGE_SIZE,
          first: null,
          before: this.pageInfo.startCursor,
        },
        updateQuery: (_, { fetchMoreResult }) => fetchMoreResult,
      });
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
        </gl-alert> -->
    <vulnerability-list
      :is-loading="this.$apollo.queries.vulnerabilities.loading"
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
    <button @click="previousPage">Previous Page</button>
    <button @click="nextPage">Next Page</button>
    <gl-pagination
      v-if="false"
      class="justify-content-center prepend-top-default"
      :per-page="$options.PAGE_SIZE"
      :total-items="30"
      :value="1"
      @input="fetchPage"
    />
  </div>
</template>
