<script>
import { GlColumnChart } from '@gitlab/ui/dist/charts';

export default {
  name: 'BarChart',
  components: {
    GlColumnChart,
  },
  props: {
    data: {
      type: Object,
      required: true,
    },
    selected: {
      type: Array,
      required: false,
      default: () => [],
    },
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
    return {};
  },
  methods: {
    onChartItemClicked(data) {
      console.log('chartItemClicked :: ', data);
    },
  },
  computed: {
    chartData() {
      const data = Object.keys(this.data).map(key => {
        const dataArr = [key, this.data[key]];

        if (this.selected.indexOf(key) !== -1) {
          return {
            value: dataArr,
            itemStyle: {
              color: '#123456',
            },
          };
        }
        return dataArr;
      });

      return {
        Full: data,
      };
    },
  },
};
</script>

<template>
  <gl-column-chart
    :data="chartData"
    :option="{}"
    :y-axis-title="yAxisTitle"
    :x-axis-title="xAxisTitle"
    @chartItemClicked="onChartItemClicked"
    x-axis-type="category"
  />
</template>
