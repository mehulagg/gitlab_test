<script>
import merge from 'lodash/merge';
import Chart from '../chart/chart.vue';
import Tooltip from '../tooltip/tooltip.vue';
import defaultChartOptions, { colors } from '../../../helpers/chart';
import hexToRgba from '../../../helpers/colors';

export default {
  components: {
    Chart,
    Tooltip,
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
      default: () => {},
    },
    formatTooltipText: {
      type: Function,
      required: false,
      default: null,
    },
  },
  data() {
    return {
      tooltipTitle: '',
      tooltipInfo: {},
    };
  },
  computed: {
    series() {
      return Object.keys(this.data).map((key, index) => {
        let colorIndex = index;
        while (colorIndex > 3) {
          colorIndex -= 4;
        }
        const lineColor = colors.lines[colorIndex];

        return {
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
        };
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
          },
          tooltip: {
            trigger: 'axis',
            formatter: this.renderTooltip,
            backgroundColor: colors.tooltipBackground,
            padding: 0,
            borderWidth: 1,
            borderColor: colors.textQuaternary,
            textStyle: {
              color: colors.textTertiary,
            },
            axisPointer: {
              lineStyle: {
                color: colors.textTertiary,
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
  methods: {
    renderTooltip(params, ticket, callback) {
      const info = {};
      const xLabels = [];
      params.forEach(line => {
        let title;
        let value;
        if (this.formatTooltipText) {
          [title, value] = this.formatTooltipText(line.value);
        } else {
          [title, value] = line.value;
        }

        info[line.seriesName] = value;
        if (!xLabels.includes(title)) {
          xLabels.push(title);
        }
      });
      this.tooltipTitle = xLabels.join(', ');
      this.tooltipInfo = info;

      this.$nextTick(() => callback(ticket, this.$refs.tooltip.$el.innerHTML));

      return ' ';
    },
  },
};
</script>

<template>
  <div>
    <chart
      v-bind="$attrs"
      :options="options"
      @created="chart => $emit('created', chart)"
      @updated="chart => $emit('updated', chart)"
    />
    <tooltip
      v-show="false"
      ref="tooltip"
      :title="tooltipTitle"
      :info="tooltipInfo"
    />
  </div>
</template>
