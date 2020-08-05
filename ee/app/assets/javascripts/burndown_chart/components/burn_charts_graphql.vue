<script>
import { getDayDifference } from '~/lib/utils/datetime_utility';
import dateFormat from 'dateformat';
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
    sparseBurnupData: {
      query: BurnupQuery,
      variables() {
        return {
          iterationId: this.iterationId,
        };
      },
      update(data) {
        return data?.iteration?.burnupTimeSeries?.nodes;
      },
    },
  },
  data() {
    return {
      sparseBurnupData: [],
    };
  },
  computed: {
    burnupData() {
      return this.sparseBurnupData.reduce((acc = [], current) => {
        const { date } = current;

        if (date !== this.startDate) {
          const { date: prevDate, ...previousValues } = acc[acc.length - 1];

          const currentDateUTC = new Date(`${date}T00:00:00`);
          const prevDateUTC = new Date(`${prevDate}T00:00:00`);

          const gap = getDayDifference(prevDateUTC, currentDateUTC);

          for (let i = 1; i < gap; i += 1) {
            const nDaysAfter = new Date(prevDateUTC).setDate(prevDateUTC.getDate() + i);
            acc.push({
              date: dateFormat(nDaysAfter, 'yyyy-mm-dd'),
              ...previousValues,
            });
          }
        }

        acc.push(current);

        return acc;
      }, []);
    },
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
      return this.burnupData.map(val => [val.date, val.scopeCount]);
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
