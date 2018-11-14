<script>
import bTooltip from 'bootstrap-vue/es/components/tooltip/tooltip';

export default {
  components: {
    bTooltip,
  },
  inheritAttrs: false,
};
</script>

<template>
  <b-tooltip v-bind="$attrs" >
    <slot></slot>
  </b-tooltip>
</template>
