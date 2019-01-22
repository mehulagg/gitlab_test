<template>
  <gl-area-chart
    :data="{Values: {0: 5, 4: 3, 8: 10}}"
    :option="{
      series: [{
        type: 'scatter',
        data: [[2, 5], [6, 10]],
      }]
    }"
  />
</template>
