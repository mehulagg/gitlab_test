<script>
export default {
  props: {
    lines: {
      type: Number,
      required: false,
      default: 3,
      validator(value) {
        return value > 0 && value < 4;
      },
    },
  },
  computed: {
    lineClasses() {
      return new Array(this.lines).fill().map((_, i) => `skeleton-line-${i + 1}`);
    },
  },
};
</script>

<template>
  <div class="animation-container">
    <div
      v-for="(css, index) in lineClasses"
      :key="index"
      :class="css"
    ></div>
  </div>
</template>
