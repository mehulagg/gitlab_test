<script>
import BFormGroup from 'bootstrap-vue/es/components/form-group/form-group';

export default {
  components: {
    BFormGroup,
  },
  inheritAttrs: false,
};
</script>
<template>
  <b-form-group v-bind="$attrs">
    <slot v-for="slot in Object.keys($slots)" :slot="slot" :name="slot"></slot>
  </b-form-group>
</template>
