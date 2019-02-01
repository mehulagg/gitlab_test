<script>
import BFormRadioGroup from 'bootstrap-vue/es/components/form-radio/form-radio-group';

export default {
  components: {
    BFormRadioGroup,
  },
  inheritAttrs: false,
};
</script>
<template>
  <b-form-radio-group plain v-bind="$attrs" v-on="$listeners" @change="$emit('change', $event)">
    <slot></slot>
  </b-form-radio-group>
</template>
