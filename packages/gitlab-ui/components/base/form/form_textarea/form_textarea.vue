<script>
import BFormTextarea from 'bootstrap-vue/es/components/form-textarea/form-textarea';

export default {
  components: {
    BFormTextarea,
  },
  inheritAttrs: false,
  props: {
    // This prop is needed to map the v-model correctly
    // https://alligator.io/vuejs/add-v-model-support/
    value: {
      type: String,
      required: false,
      default: '',
    },
  },
};
</script>

<template>
  <b-form-textarea
    v-bind="$attrs"
    :value="value"
    v-on="$listeners"
  />
</template>
