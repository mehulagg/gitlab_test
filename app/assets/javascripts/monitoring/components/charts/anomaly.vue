<script>
import { GlLineChart, GlChartSeriesLabel } from '@gitlab/ui/dist/charts';
import { roundOffFloat } from '~/lib/utils/common_utils';
import { hexToRgb } from '~/lib/utils/color_utils';
import { areaOpacityValues, symbolSizes, colorValues } from '../../constants';
import { graphDataValidatorForAnomalyValues } from '../../utils';
import MonitorTimeSeriesChart from './time_series.vue';

export default {
  components: {
    GlLineChart,
    GlChartSeriesLabel,
    MonitorTimeSeriesChart,
  },
  inheritAttrs: false,
  props: {
    graphData: {
      type: Object,
      required: true,
      validator: graphDataValidatorForAnomalyValues,
    },
    containerWidth: {
      type: Number,
      required: true,
    },
    deploymentData: {
      type: Array,
      required: false,
      default: () => [],
    },
    projectPath: {
      type: String,
      required: false,
      default: '',
    },
    singleEmbed: {
      type: Boolean,
      required: false,
      default: false,
    },
    thresholds: {
      type: Array,
      required: false,
      default: () => [],
    },
  },
  data() {
    return {
      tooltip: {
        title: '',
        content: [],
        commitUrl: '',
        isDeployment: false,
        sha: '',
      },
      areaColor: colorValues.anomalyAreaColor,
      areaOpacity: areaOpacityValues.default,
    };
  },
  computed: {
    series() {
      return this.graphData.queries.map(query => {
        const values = query.result[0] ? query.result[0].values : [];
        return {
          label: query.label,
          data: values.filter(([, value]) => !Number.isNaN(value)),
        };
      });
    },
    yOffset() {
      // in case the any part of the chart is displayed below 0
      // calculate an offset for the whole chart, so the area can be displayed above it
      const minVals = this.series.map(ser =>
        ser.data.reduce((min, datapoint) => {
          const [, yVal] = datapoint;
          return Math.floor(Math.min(min, yVal));
        }, Infinity),
      );
      return -Math.min(...minVals);
    },
    metricData() {
      const originalMetricQuery = this.graphData.queries[0];

      const metricQuery = { ...originalMetricQuery };
      metricQuery.result[0].values = metricQuery.result[0].values.map(([x, y]) => [
        x,
        y + this.yOffset,
      ]);
      return {
        ...this.graphData,
        type: 'line-chart',
        queries: [metricQuery],
      };
    },
    areaColorRgba() {
      const rgb = hexToRgb(this.areaColor);
      return `rgba(${rgb.join(',')},${this.areaOpacity})`;
    },
    chartDataConfig() {
      return {
        type: 'line',
        symbol: 'circle',
        symbolSize: (val, params) => {
          if (this.isDatapointAnomaly(params.dataIndex)) {
            return symbolSizes.anomaly;
          }
          // 0 causes echarts to throw an error, use small number instead
          // see https://gitlab.com/gitlab-org/gitlab-ui/issues/423
          return 0.001;
        },
        showSymbol: true,
        itemStyle: {
          color: params => {
            if (this.isDatapointAnomaly(params.dataIndex)) {
              return colorValues.anomalySymbol;
            }
            return colorValues.primaryColor;
          },
        },
      };
    },
    chartOptions() {
      const calcOffsetY = (data, offsetCallback) =>
        data.map((value, valueIndex) => {
          const [x, y] = value;
          return [x, y + offsetCallback(valueIndex)];
        });

      const [, lowerSeries, upperSeries] = this.series;

      return {
        yAxis: {
          name: this.yAxisLabel,
          axisLabel: {
            formatter: num => roundOffFloat(num - this.yOffset, 3).toString(),
          },
        },
        series: [
          // The boundary is rendered by 2 series
          // One area invisible series (opacity: 0) stacked on a visible one
          this.makeBoundarySeries({
            name: this.formatLegendLabel(upperSeries),
            data: calcOffsetY(upperSeries.data, () => this.yOffset),
          }),
          this.makeBoundarySeries({
            name: this.formatLegendLabel(lowerSeries),
            data: calcOffsetY(lowerSeries.data, i => -upperSeries.data[i][1]),
            areaStyle: {
              color: this.areaColor,
              opacity: this.areaOpacity,
            },
          }),
        ],
      };
    },
  },
  methods: {
    formatLegendLabel(query) {
      return query.label;
    },
    getSeriesValue(seriesIndex, dataIndex) {
      return this.series[seriesIndex].data[dataIndex];
    },
    getYValueFormatted(seriesIndex, dataIndex) {
      const [, y] = this.getSeriesValue(seriesIndex, dataIndex);
      return y.toFixed(3);
    },
    isDatapointAnomaly(dataIndex) {
      const [, yVal] = this.getSeriesValue(0, dataIndex);
      const [, yUpper] = this.getSeriesValue(1, dataIndex);
      const [, yLower] = this.getSeriesValue(2, dataIndex);
      return yVal < yLower || yVal > yUpper;
    },
    makeBoundarySeries(series) {
      const stackKey = 'anomaly-boundary-series-stack';
      return {
        type: 'line',
        stack: stackKey,
        lineStyle: {
          width: 0,
          color: this.areaColorRgba, // legend color
        },
        color: this.areaColorRgba, // tooltip color
        symbol: 'none',
        ...series,
      };
    },
  },
};
</script>

<template>
  <monitor-time-series-chart
    :graph-data="metricData"
    :addtional-chart-options="chartOptions"
    :addtional-chart-data-config="chartDataConfig"
    :deployment-data="deploymentData"
    :thresholds="thresholds"
    :container-width="containerWidth"
    :project-path="projectPath"
  >
    <slot></slot>
    <template v-slot:tooltipTitle="slotProps">
      <div class="text-nowrap">
        {{ slotProps.tooltip.title }}
      </div>
    </template>
    <template v-slot:tooltipContent="slotProps">
      <div
        v-for="(content, seriesIndex) in slotProps.tooltip.content"
        :key="seriesIndex"
        class="d-flex justify-content-between"
      >
        <gl-chart-series-label :color="content.color">
          {{ content.name }}
        </gl-chart-series-label>
        <div class="prepend-left-32">
          {{ getYValueFormatted(seriesIndex, content.dataIndex) }}
        </div>
      </div>
    </template>
  </monitor-time-series-chart>
</template>
