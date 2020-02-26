<script>
import { ApolloQuery } from 'vue-apollo';
import { GlAlert, GlEmptyState, GlPagination } from '@gitlab/ui';

import VulnerabilityList from 'ee/vulnerabilities/components/vulnerability_list.vue';
import vulnerabilitiesQuery from '../graphgql/vulnerabilities.gql';

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
          fullPath: 'root/yarn-autoremediation-test',
        };
      },
      update: data => data.project.vulnerabilities.nodes,
    },
  },
  computed: {
    // vulnerabilitiesQueryBody() {
    //   return {
    //     query: vulnerabilitiesQuery,
    //     variables: { fullPath: 'root/yarn-autoremediation-test' },
    //   };
    // },
  },
  created() {},
  methods: {
    fetchPage(page) {
      // this.fetchVulnerabilities({ ...this.activeFilters, page });
    },
  },
};
</script>

<template>
  <div>
    <!-- <apollo-query :query="vulnerabilitiesQueryBody"> -->
    <!-- <template slot-scope="{ result: { data, loading } }"> -->
    <!-- <gl-alert v-if="errorLoadingVulnerabilities" :dismissible="false" variant="danger">
          {{
            s__(
              'Security Dashboard|Error fetching the vulnerability list. Please check your network connection and try again.',
            )
          }}
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
    <gl-pagination
      v-if="pageInfo.total > 1"
      class="justify-content-center prepend-top-default"
      :per-page="pageInfo.perPage"
      :total-items="pageInfo.total"
      :value="pageInfo.page"
      @input="fetchPage"
    />
    <!-- </template> -->
    <!-- </apollo-query> -->
  </div>
</template>
