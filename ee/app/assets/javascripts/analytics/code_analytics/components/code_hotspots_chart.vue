<script>
import { s__ } from '~/locale';
import { debounceByAnimationFrame } from '~/lib/utils/common_utils';
import { GlLink } from '@gitlab/ui';
import { GlChart, GlChartTooltip } from '@gitlab/ui/dist/charts';
import { green500, orange500, red500 } from '@gitlab/ui/scss_to_js/scss_variables';
import { hexToRgb } from '~/lib/utils/color_utils';
import { DEFAULT_SPACING } from '../constants';
import CodeHotspotsChartLegend from './code_hotspots_chart_legend.vue';

const green = hexToRgb(green500);
const orange = hexToRgb(orange500);
const red = hexToRgb(red500);

const opacity = [0.2, 0.4, 0.6, 0.8];

const DEFAULT_COLORS = [
  `rgba(${green}, ${opacity[0]})`,
  `rgba(${green}, ${opacity[1]})`,
  `rgba(${green}, ${opacity[2]})`,
  `rgba(${green}, ${opacity[3]})`,
  `rgba(${orange}, ${opacity[3]})`,
  `rgba(${red}, ${opacity[3]})`,
];

export default {
  components: {
    GlChart,
    GlChartTooltip,
    GlLink,
    CodeHotspotsChartLegend,
  },
  props: {
    data: {
      type: Array,
      required: true,
    },
    legendTitle: {
      type: String,
      required: true,
    },
  },
  colors: DEFAULT_COLORS,
  data() {
    return {
      chart: null,
      showTooltip: false,
      tooltipTitle: {
        link: '',
        name: '',
      },
      tooltipContent: {
        title: '',
        value: '',
      },
      tooltipPosition: {
        left: '0',
        top: '0',
      },
      debounceDisplayAndPositionTooltip: debounceByAnimationFrame(this.displayAndPositionTooltip),
    };
  },
  computed: {
    options() {
      return {
        title: {
          show: false,
        },
        tooltip: {
          formatter: this.onLabelChange,
        },
        series: {
          left: 0,
          top: 0,
          width: '100%',
          height: '100%',
          type: 'treemap',
          drillDownIcon: '',
          roam: false,
          nodeClick: false,
          leafDepth: 2,
          colorMappingBy: 'value',
          breadcrumb: {
            show: false,
          },
          label: {
            show: false,
          },
          levels: [
            {
              color: this.$options.colors,
              visualMin: 0,
            },
          ],
          itemStyle: {
            normal: {
              borderWidth: 3,
              borderColor: 'white',
              gapWidth: 3,
            },
          },
          data: this.data,
        },
      };
    },
  },
  beforeDestroy() {
    this.chart.getDom().removeEventListener('mousemove', this.debounceDisplayAndPositionTooltip);
    this.chart.getDom().removeEventListener('mouseout', this.debounceDisplayAndPositionTooltip);
  },
  methods: {
    updateTooltipText(params) {
      const {
        data: { name, value, link },
      } = params;
      this.tooltipTitle = {
        link,
        name,
      };
      this.tooltipContent = {
        title: s__('CodeAnalytics|Commits'),
        value,
      };
    },
    onCreated(chart) {
      chart.getDom().addEventListener('mousemove', this.debounceDisplayAndPositionTooltip);
      chart.getDom().addEventListener('mouseout', this.debounceDisplayAndPositionTooltip);
      this.chart = chart;
      this.$emit('created', chart);
    },
    shouldShowTooltip(mouseEvent) {
      return this.tooltipTitle.name && this.cursorInBounds(mouseEvent);
    },
    cursorInBounds(mouseEvent) {
      const x = mouseEvent.zrX;
      const y = mouseEvent.zrY;

      const width = this.chart.getWidth();
      const height = this.chart.getHeight();

      // Method used for other echarts not supported over here
      // https://www.echartsjs.com/en/api.html#echartsInstance.containPixel
      return (
        x > DEFAULT_SPACING &&
        x < width - DEFAULT_SPACING &&
        y > DEFAULT_SPACING &&
        y < height - DEFAULT_SPACING
      );
    },
    setTooltipPosition(mouseEvent) {
      this.tooltipPosition = {
        left: `${mouseEvent.zrX}px`,
        top: `${mouseEvent.zrY - DEFAULT_SPACING}px`,
      };
    },
    displayAndPositionTooltip(mouseEvent) {
      this.setTooltipPosition(mouseEvent);
      this.showTooltip = this.shouldShowTooltip(mouseEvent);
    },
    onLabelChange(params) {
      this.updateTooltipText(params);
    },
  },
};
</script>

<template>
  <div>
    <gl-chart :options="options" @created="onCreated" />
    <gl-chart-tooltip
      v-if="chart"
      :show="showTooltip"
      :chart="chart"
      :top="tooltipPosition.top"
      :left="tooltipPosition.left"
      placement="top"
    >
      <div slot="title">
        <gl-link :href="tooltipTitle.link" target="_blank" class="text-bold text-dark">{{
          tooltipTitle.name
        }}</gl-link>
      </div>
      <div>
        <strong>{{ tooltipContent.value }}</strong>
        {{ tooltipContent.title }}
      </div>
    </gl-chart-tooltip>
    <code-hotspots-chart-legend :colors="this.$options.colors" :title="legendTitle" />
  </div>
</template>
