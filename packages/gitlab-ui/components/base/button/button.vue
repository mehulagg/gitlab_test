<script>
import BButton from 'bootstrap-vue/es/components/button/button';
import RelMixin from '../../mixins/rel_mixin';

export default {
  components: {
    BButton,
  },
  mixins: [RelMixin],
};
</script>
<template>
  <b-button
    v-bind="$attrs"
    :rel="relType"
    :target="target"
    v-on="$listeners"
  >
    <slot />
  </b-button>
</template>
