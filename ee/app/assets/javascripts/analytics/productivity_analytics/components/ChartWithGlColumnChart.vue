<script>
import { GlColumnChart } from '@gitlab/ui/dist/charts';

export default {
  name: 'ChartWithGlColumnChart',
  props: {},
  components: {
    GlColumnChart,
  },
  data() {
    return {
      data: [
        { value: [1, 12] },
        { value: [2, 4] },
        { value: [3, 9] },
        { value: [4, 23] },
        { value: [5, 16] },
      ],
      selected: [],
    };
  },
  computed: {
    chartData() {
      const dataWithSelected = this.data.map((d, i) => {
        if (this.selected.indexOf(d.value[0]) !== -1) {
          return { ...d, itemStyle: { color: '#123456' } };
        } else {
          return { value: d.value };
        }
      });

      return {
        Full: dataWithSelected,
      };
    },
  },
  methods: {
    onMainChartItemClicked({ params }) {
      const { data } = params;
      const foundIdx = this.selected.indexOf(data.value[0]);
      if (foundIdx === -1) {
        this.selected.push(data.value[0]);
      } else {
        this.selected.splice(foundIdx, 1);
      }
    },
  },
};
</script>

<style></style>

<template>
  <gl-column-chart
    :data="chartData"
    x-axis-type="category"
    x-axis-title="x axis"
    y-axis-title="y axis"
    @chartItemClicked="onMainChartItemClicked"
  />
</template>
