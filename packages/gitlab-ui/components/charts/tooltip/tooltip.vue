<script>
export default {
  props: {
    title: {
      type: String,
      required: true,
    },
    info: {
      type: Object,
      required: true,
      validator(info) {
        const invalidValues = Object.values(info).filter(
          value => !Number.isFinite(value) && typeof value !== 'string'
        );

        return invalidValues.length === 0;
      },
    },
  },
};
</script>

<template>
  <div
    class="popover"
    role="tooltip"
  >
    <h3 class="js-header popover-header">
      {{ title }}
    </h3>
    <div class="popover-body">
      <div
        v-for="(value, name) in info"
        :key="name + '-' + value"
        class="js-body-value"
      >
        <span>
          {{ name }}
        </span>
        <span class="ml-1">
          {{ value }}
        </span>
      </div>
    </div>
  </div>
</template>
