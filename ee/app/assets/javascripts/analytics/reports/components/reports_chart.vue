<script>
import { GlColumnChart, GlChartLegend } from '@gitlab/ui/dist/charts';
import { GlLoadingIcon } from '@gitlab/ui';
import { mapState, mapActions, mapGetters } from 'vuex';
import { CHART_HEIGHT } from 'ee/analytics/reports/constants';

export default {
  name: 'ReportsChart',
  components: {
    GlColumnChart,
    GlChartLegend,
    GlLoadingIcon,
  },
  props: {
    xAxisTitle: {
      type: String,
      required: false,
      default: '',
    },
    yAxisTitle: {
      type: String,
      required: false,
      default: '',
    },
  },
  data() {
    return {
      chart: null,
    };
  },
  computed: {
    ...mapState('chart', ['isLoading']),
    ...mapGetters('chart', ['columnChartData', 'displayChart', 'seriesInfo']),
  },
  mounted() {
    this.fetchChartSeriesData();
  },
  methods: {
    ...mapActions('chart', ['fetchChartSeriesData']),
    onCreated(chart) {
      this.chart = chart;
    },
  },
  height: CHART_HEIGHT,
};
</script>
<template>
  <div>
    <gl-loading-icon v-if="isLoading" size="md" />
    <gl-column-chart
      v-if="displayChart"
      :height="$options.height"
      :data="columnChartData"
      x-axis-type="category"
      :x-axis-title="xAxisTitle"
      :y-axis-title="yAxisTitle"
      @created="onCreated"
    />
    <gl-chart-legend v-if="chart" :chart="chart" :series-info="seriesInfo" />
  </div>
</template>
