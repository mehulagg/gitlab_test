<script>
import BTabs from 'bootstrap-vue/es/components/tabs/tabs';

export default {
  components: {
    BTabs,
  },
  inheritAttrs: false,
};
</script>

<template>
  <b-tabs v-bind="$attrs" v-on="$listeners">
    <slot></slot>
  </b-tabs>
</template>
