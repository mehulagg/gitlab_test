<script>
import bProgress from 'bootstrap-vue/es/components/progress/progress';

export default {
  components: {
    bProgress,
  },
};
</script>

<style>
.progress {
  height: 6px;
}
</style>

<template>
  <b-progress v-bind="$attrs" />
</template>
