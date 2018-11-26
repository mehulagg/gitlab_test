<script>
export default {
  props: {
    label: {
      type: String,
      required: false,
      default: 'Loading',
    },
    size: {
      type: Number,
      required: false,
      default: 1,
      validator(value) {
        return value > 0 && value < 6;
      },
    },
    inline: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  computed: {
    rootElementType() {
      return this.inline ? 'span' : 'div';
    },
    cssClass() {
      return `fa-${this.size}x fa-spin`;
    },
  },
};
</script>
<template>
  <component
    :is="rootElementType"
    class="loading-container text-center"
  >
    <i
      :class="cssClass"
      :aria-label="label"
      class="fa fa-spinner"
      aria-hidden="true"
    ></i>
  </component>
</template>
