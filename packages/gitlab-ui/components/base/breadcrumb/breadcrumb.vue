<script>
import BBreadcrumb from 'bootstrap-vue/es/components/breadcrumb/breadcrumb';

export default {
  components: {
    BBreadcrumb,
  },
  inheritAttrs: false,
};
</script>
<template>
  <b-breadcrumb
    v-bind="$attrs"
    v-on="$listeners"
  />
</template>
