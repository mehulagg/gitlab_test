<script>
export default {
  props: {
    index: {
      required: true,
      type: Number,
    },
    strategy: {
      required: true,
      type: Object,
    },
    userLists: {
      required: true,
      type: Array,
    },
  },
};
</script>
<template>
  <div>
    <slot v-bind="$props"></slot>
  </div>
</template>
