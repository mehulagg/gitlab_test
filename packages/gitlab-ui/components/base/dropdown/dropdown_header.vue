<script>
import BDropdownHeader from 'bootstrap-vue/es/components/dropdown/dropdown-header';

export default {
  components: {
    BDropdownHeader,
  },
  inheritAttrs: false,
};
</script>

<template>
  <b-dropdown-header
    v-bind="$attrs"
    v-on="$listeners"
  >
    <slot></slot>
  </b-dropdown-header>
</template>
