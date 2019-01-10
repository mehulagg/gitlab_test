<script>
import isEmpty from 'lodash/isEmpty';
import merge from 'lodash/merge';
import Chart from '../chart/chart.vue';
import ChartTooltip from '../tooltip/tooltip.vue';
import defaultChartOptions, { colors, getThresholdConfig } from '../../../helpers/chart';
import { hexToRgba, debounceByAnimationFrame } from '../../../helpers/utils';

export default {
  components: {
    Chart,
    ChartTooltip,
  },
  inheritAttrs: false,
  props: {
    data: {
      type: Object,
      required: true,
    },
    option: {
      type: Object,
      required: false,
      default: () => ({}),
    },
    thresholds: {
      type: Object,
      required: false,
      default: () => ({}),
    },
    formatTooltipText: {
      type: Function,
      required: false,
      default: null,
    },
  },
  data() {
    return {
      chart: null,
      showTooltip: false,
      tooltipTitle: '',
      tooltipContent: {},
      tooltipPosition: {
        left: '0',
        top: '0',
      },
      debouncedShowHideTooltip: debounceByAnimationFrame(this.showHideTooltip),
    };
  },
  computed: {
    hasTooltipContent() {
      return !isEmpty(this.tooltipContent);
    },
    series() {
      return Object.keys(this.data).map((key, index) => {
        let colorIndex = index;
        const lineColorsCount = colors.lines.length;
        while (colorIndex >= lineColorsCount) {
          colorIndex -= lineColorsCount;
        }
        const lineColor = colors.lines[colorIndex];

        return Object.assign(
          {
            name: key,
            data: Object.entries(this.data[key]),
            type: 'line',
            showSymbol: false,
            symbol: 'circle',
            symbolSize: 3,
            lineStyle: {
              width: 1,
            },
            itemStyle: {
              color: lineColor,
            },
            areaStyle: {
              color: hexToRgba(lineColor, 0.2),
            },
          },
          this.thresholds === null ? {} : getThresholdConfig(this.thresholds)
        );
      });
    },
    options() {
      return merge(
        {},
        defaultChartOptions,
        {
          xAxis: {
            axisLabel: {
              margin: 20,
              verticalAlign: 'bottom',
            },
            axisPointer: {
              show: true,
              lineStyle: {
                color: colors.textTertiary,
              },
              label: {
                show: false,
                formatter: this.onLabelChange,
              },
            },
          },
          series: this.series,
          legend: {
            itemWidth: 16,
          },
        },
        this.option
      );
    },
  },
  beforeDestroy() {
    this.chart.getDom().removeEventListener('mousemove', this.debouncedShowHideTooltip);
    this.chart.getDom().removeEventListener('mouseout', this.debouncedShowHideTooltip);
  },
  methods: {
    onCreated(chart) {
      chart.getDom().addEventListener('mousemove', this.debouncedShowHideTooltip);
      chart.getDom().addEventListener('mouseout', this.debouncedShowHideTooltip);
      this.chart = chart;
      this.$emit('created', chart);
    },
    showHideTooltip(mouseEvent) {
      this.showTooltip =
        this.chart.containPixel('grid', [mouseEvent.zrX, mouseEvent.zrY]) && this.hasTooltipContent;
    },
    onUpdated(chart) {
      this.$emit('updated', chart);
    },
    onLabelChange(params) {
      this.tooltipContent = {};
      const xLabels = [];
      params.seriesData.forEach(line => {
        let title;
        let value;
        if (this.formatTooltipText) {
          [title, value] = this.formatTooltipText(line.value);
        } else {
          [title, value] = line.value;
        }

        if (!xLabels.includes(title)) {
          xLabels.push(title);
        }

        this.$set(this.tooltipContent, line.seriesName, value);
      });
      this.tooltipTitle = xLabels.join(', ');

      if (params.seriesData.length) {
        const [left, top] = this.chart.convertToPixel('grid', params.seriesData[0].data);
        this.tooltipPosition = {
          left: `${left}px`,
          top: `${top}px`,
        };
      }
    },
  },
};
</script>

<template>
  <div class="position-relative">
    <chart
      v-bind="$attrs"
      :options="options"
      @created="onCreated"
      @updated="onUpdated"
    />
    <chart-tooltip
      v-if="chart"
      :show="showTooltip"
      :chart="chart"
      :top="tooltipPosition.top"
      :left="tooltipPosition.left"
    >
      <div slot="title">
        {{ tooltipTitle }}
      </div>
      <div
        v-for="(value, label) in tooltipContent"
        :key="label + value"
      >
        {{ label }}
        {{ value }}
      </div>
    </chart-tooltip>
  </div>
</template>
