<script>
import { GlLineChart } from '@gitlab/ui/dist/charts';
import dateFormat from 'dateformat';
import ResizableChartContainer from '~/vue_shared/components/resizable_chart/resizable_chart_container.vue';
import { __, sprintf } from '~/locale';

export default {
  components: {
    GlLineChart,
    ResizableChartContainer,
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
    scope: {
      type: Array,
      required: false,
      default: () => [],
    },
    issuesSelected: {
      type: Boolean,
      required: false,
      default: true,
    },
  },
  data() {
    return {
      tooltip: {
        title: '',
        content: '',
      },
    };
  },
  computed: {
    dataSeries() {
      const series = [
        {
          name: __('Issues'),
          data: this.scope,
        },
      ];

      return series;
    },
    options() {
      return {
        xAxis: {
          name: '',
          type: 'time',
          min: this.startDate,
          max: this.dueDate,
          axisLine: {
            show: true,
          },
        },
        yAxis: {
          name: this.issuesSelected ? __('Total issues') : __('Total weight'),
          axisLine: {
            show: true,
          },
          splitLine: {
            show: false,
          },
        },
        tooltip: {
          trigger: 'item',
          formatter: () => '',
        },
      };
    },
  },
  methods: {
    formatTooltipText(params) {
      const [seriesData] = params.seriesData;
      this.tooltip.title = dateFormat(params.value, 'dd mmm yyyy');

      if (this.issuesSelected) {
        this.tooltip.content = sprintf(__('%{total} open issues'), {
          total: seriesData.value[1],
        });
      } else {
        this.tooltip.content = sprintf(__('%{total} open issue weight'), {
          total: seriesData.value[1],
        });
      }
    },
    showIssueCount() {
      this.issuesSelected = true;
    },
    showIssueWeight() {
      this.issuesSelected = false;
    },
  },
};
</script>

<template>
  <div data-qa-selector="burnup_chart">
    <div class="burndown-header d-flex align-items-center">
      <h3>{{ __('Burnup chart') }}</h3>
    </div>
    <resizable-chart-container class="burndown-chart">
      <gl-line-chart
        slot-scope="{ width }"
        :width="width"
        :data="dataSeries"
        :option="options"
        :format-tooltip-text="formatTooltipText"
      >
        <template slot="tooltipTitle">{{ tooltip.title }}</template>
        <template slot="tooltipContent">{{ tooltip.content }}</template>
      </gl-line-chart>
    </resizable-chart-container>
  </div>
</template>
