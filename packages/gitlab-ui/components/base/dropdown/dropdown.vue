<script>
import BDropdown from 'bootstrap-vue/es/components/dropdown/dropdown';

export default {
  components: {
    BDropdown,
  },
  inheritAttrs: false,
  props: {
    text: {
      type: String,
      required: false,
      default: '',
    },
  },
};
</script>

<template>
  <b-dropdown
    v-bind="$attrs"
    v-on="$listeners"
  >
    <slot></slot>
    <slot
      slot="button-content"
      name="button-content"
    >
      {{ text }}
      <i
        class="fa fa-chevron-down"
        aria-hidden="true"
      ></i>
    </slot>
  </b-dropdown>
</template>
