<script>
import BDropdownItem from 'bootstrap-vue/es/components/dropdown/dropdown-item';
import BDropdownItemButton from 'bootstrap-vue/es/components/dropdown/dropdown-item-button';

export default {
  inheritAttrs: false,
  computed: {
    bootstrapComponent() {
      return this.$attrs.href ? BDropdownItem : BDropdownItemButton;
    },
  },
};
</script>

<template>
  <component
    :is="bootstrapComponent"
    v-bind="$attrs"
    v-on="$listeners"
  >
    <slot></slot>
  </component>
</template>
