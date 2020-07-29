<script>
import BurnCharts from './burn_charts.vue';
import BurnupQuery from '../queries/burnup.query.graphql';

export default {
  components: {
    BurnCharts,
  },
  props: {
    startDate: {
      type: String,
      required: true,
    },
    dueDate: {
      type: String,
      required: true,
    },
    iterationId: {
      type: String,
      required: true,
    },
  },
  apollo: {
    burnupData: {
      query: BurnupQuery,
      variables() {
        return {
          iterationId: this.iterationId,
        };
      },
      update(data) {
        // TODO: remove the empty array..
        return [] || data?.group?.iterations.nodes[0]?.data?.nodes;
      },
    },
  },
  data() {
    return {
      burnupData: [],
    };
  },
  computed: {
    openIssuesCount() {
      return this.burnupData.map(({ date, scopeCount, completedCount }) => {
        return [date, scopeCount - completedCount];
      });
    },
    openIssuesWeight() {
      return this.burnupData.map(({ date, scopeWeight, completedWeight }) => {
        return [date, scopeWeight - completedWeight];
      });
    },
    burnupScope() {
      // TODO: data in graphql response is sparse dates, go through list and
      // fill in dates where there is more than a one day gap
      return this.burnupData;
    },
  },
};
</script>

<template>
  <burn-charts
    :start-date="startDate"
    :due-date="dueDate"
    :open-issues-count="openIssuesCount"
    :open-issues-weight="openIssuesWeight"
    :burnup-scope="burnupScope"
  />
</template>
