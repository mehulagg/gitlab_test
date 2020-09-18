<script>
import { GlEmptyState } from '@gitlab/ui';

export default {
  name: 'SearchEmptyState',
  components: {
    GlEmptyState,
  },
  props: {
    searchEmptySvgPath: {
      type: String,
      required: true,
    },
  },
};
</script>

<template>
  <gl-empty-state
    :title="__('No results found')"
    :description="__('Please try searching for something else.')"
    :svg-path="searchEmptySvgPath"
  />
</template>
