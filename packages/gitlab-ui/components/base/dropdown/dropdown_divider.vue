<script>
import BDropdownDivider from 'bootstrap-vue/es/components/dropdown/dropdown-divider';

export default {
  components: {
    BDropdownDivider,
  },
  inheritAttrs: false,
};
</script>

<template>
  <b-dropdown-divider
    v-bind="$attrs"
    v-on="$listeners"
  />
</template>
