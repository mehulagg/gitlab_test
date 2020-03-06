<script>
export default {
  name: 'GroupActivityCard',
  props: {
    groupFullPath: {
      type: String,
      required: true,
    },
  },
};
</script>

<template>
  <div>{{ __('Group analytics activity goes here') }}</div>
</template>
