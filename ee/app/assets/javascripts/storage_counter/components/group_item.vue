<script>
/* eslint-disable vue/no-v-html */
export default {
  props: {
    project: {
      type: Object,
      required: false,
      default: () => ({}),
    },
  },
};
</script>

<template>
  <li class="group-row">
    {{ project.name }}
  </li>
</template>
