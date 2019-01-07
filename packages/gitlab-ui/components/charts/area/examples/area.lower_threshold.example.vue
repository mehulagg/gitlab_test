<template>
  <gl-area-chart
    :data="{Values: {0: 5, 4: 3, 8: 10}}"
    :thresholds="{
      0: {
        threshold: 4,
        operator: '<',
      }
    }"
  />
</template>
