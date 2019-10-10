<script>
export default {
  props: {
    colors: {
      type: Array,
      required: true,
    },
    title: {
      type: String,
      required: true,
    },
  },
  size: 32,
  methods: {
    styles(color) {
      return [
        `background-color:${color};`,
        `height:${this.$options.size}px;`,
        `width:${this.$options.size}px;`,
      ].join(' ');
    },
  },
};
</script>
<template>
  <div>
    <div class="d-flex mt-6">
      <span v-for="color in colors" :key="color" :style="styles(color)"></span>
    </div>
    <div class="d-flex mt-1">{{ title }}</div>
  </div>
</template>
