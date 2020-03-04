<script>
import { mapActions } from 'vuex';
import { GlSkeletonLoader } from '@gitlab/ui';

export default {
  components: { GlSkeletonLoader },
  props: {
    tagId: {
      type: String,
      required: true,
    },
  },
  loader: {
    width: 250,
    height: 40,
  },
  data() {
    return {
      isLoading: false,
    };
  },
  mounted() {
    this.isLoading = true;
    return this.requestTagDetails(this.tagId).then(() => {
      this.isLoading = false;
    });
  },
  methods: {
    ...mapActions(['requestTagDetails']),
  },
};
</script>
<template>
  <span>
    <slot v-if="!isLoading"> </slot>

    <gl-skeleton-loader
      v-else
      :width="$options.loader.width"
      :height="$options.loader.height"
      preserve-aspect-ratio="xMinYMax meet"
    >
      <rect width="250" x="25" y="10" height="20" rx="4" />
    </gl-skeleton-loader>
  </span>
</template>

<style></style>
