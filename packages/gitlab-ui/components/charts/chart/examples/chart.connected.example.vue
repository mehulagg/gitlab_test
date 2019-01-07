<script>
export default {
  methods: {
    optionsFromData(data) {
      return {
        xAxis: {
          type: 'category',
          data: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
        },
        yAxis: {
          type: 'value',
        },
        axisPointer: {
          show: true,
        },
        series: [
          {
            data,
            type: 'bar',
          },
        ],
      };
    },
  },
};
</script>

<template>
  <div>
    <gl-chart
      group-id="connected-chart-unique-id"
      :options="optionsFromData([820, 932, 901, 934, 1290, 1330, 1320])"
    />
    <gl-chart
      group-id="connected-chart-unique-id"
      :options="optionsFromData([540, 759, 140, 757, 675, 1500, 457])"
    />
  </div>
</template>
