<script>
import BPopover from 'bootstrap-vue/es/components/popover/popover';

export default {
  components: {
    BPopover,
  },
  inheritAttrs: false,
};
</script>

<template>
  <b-popover v-bind="$attrs">
    <slot></slot>
  </b-popover>
</template>
