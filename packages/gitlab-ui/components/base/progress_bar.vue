<script>
import bProgress from 'bootstrap-vue/es/components/progress/progress';

export default {
  components: {
    bProgress,
  },
};
</script>

<template>
  <b-progress v-bind="$attrs" />
</template>
