<script>
import { GlCard, GlSkeletonLoader } from '@gitlab/ui';

export default {
  name: 'SearchLoading',
  components: {
    GlCard,
    GlSkeletonLoader,
  },
};
</script>
<template>
  <gl-card>
    <gl-skeleton-loader :height="40">
      <rect y="0" width="66%" height="8" rx="4" />
      <rect y="10" width="40%" height="4" rx="2" />
      <rect y="18" width="60%" height="6" rx="3" />
      <rect y="26" width="60%" height="6" rx="3" />
      <rect y="34" width="30%" height="6" rx="3" />
    </gl-skeleton-loader>
  </gl-card>
</template>
