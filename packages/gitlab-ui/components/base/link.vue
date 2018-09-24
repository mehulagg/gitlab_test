<script>
import BLink from 'bootstrap-vue/es/components/link/link';

export default {
  components: {
    BLink
  },
  props: {
    target: {
      type: String,
      required: false,
      default: null,
    },
  },
  computed: {
    relType() {
      if (this.$attrs.rel && this.$attrs.rel.length > 0) return this.$attrs.rel;

      return this.target === '_blank' ? 'noopener noreferrer' : '';
    },
  },
};
</script>
<template>
  <b-link
    v-bind="$attrs"
    v-on="$listeners"
    :rel="relType"
    :target="target"
  >
    <slot></slot>
  </b-link>
</template>
