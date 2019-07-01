<script>
import { mapState, mapActions } from 'vuex';
import EmptyState from './empty_state.vue';
import BarChart from './bar_chart.vue';

export default {
  components: {
    EmptyState,
    BarChart,
  },
  props: {
    endpoint: {
      type: String,
      required: true,
    },
    emptyStateSvgPath: {
      type: String,
      required: true,
    },
  },
  computed: {
    ...mapState(['filters', 'charts']),
    chartData() {
      return this.charts.main.data;
    },
    selectedChartData() {
      return this.charts.main.selected;
    },
  },
  methods: {
    ...mapActions(['setChartEndpoint', 'fetchChartData']),
  },
  mounted() {
    this.setChartEndpoint(this.endpoint);
    this.fetchChartData();
  },
};
</script>

<template>
  <div>
    <empty-state v-if="!filters.groupId" :empty-state-svg-path="emptyStateSvgPath"></empty-state>
    <template v-else>
      <div>Filters/dropdowns go here</div>
      <bar-chart
        v-if="chartData"
        :data="chartData"
        :selected="selectedChartData"
        :y-axis-title="__('Merge requests')"
        :x-axis-title="__('Days')"
      ></bar-chart>
    </template>
  </div>
</template>
