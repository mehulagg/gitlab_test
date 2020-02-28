<script>
export default {
  props: {
    options: {
      type: Object,
      required: false,
      default: () => ({
        rootMargin: '25% 0px',
        threshold: 0.1,
      }),
    },
  },
  data: () => ({
    observer: null,
  }),
  mounted() {
    this.observer = new IntersectionObserver(([entry]) => {
      if (entry && entry.isIntersecting) {
        this.$emit('intersect');
      }
    }, this.options);

    this.observer.observe(this.$el);
  },
  destroyed() {
    this.observer.disconnect();
  },
};
</script>

<template>
  <div class="observer">
    <slot></slot>
  </div>
</template>
