<script>
import BLink from 'bootstrap-vue/es/components/link/link';
import RelMixin from '../../mixins/rel_mixin';

export default {
  components: {
    BLink,
  },
  mixins: [RelMixin],
};
</script>
<template>
  <b-link
    v-bind="$attrs"
    :rel="relType"
    :target="target"
    v-on="$listeners"    
  >
    <slot></slot>
  </b-link>
</template>
