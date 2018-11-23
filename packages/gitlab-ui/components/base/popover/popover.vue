<script>
import bPopover from 'bootstrap-vue/es/components/popover/popover';

export default {
  components: {
    bPopover,
  },
  inheritAttrs: false,
};
</script>

<template>
  <b-popover v-bind="$attrs">
    <slot></slot>
  </b-popover>
</template>
