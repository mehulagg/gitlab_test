<script>
import BProgress from 'bootstrap-vue/es/components/progress/progress';

export default {
  components: {
    BProgress,
  },
};
</script>

<template>
  <b-progress v-bind="$attrs" />
</template>
