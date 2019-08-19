<script>
import { GlToggle } from '@gitlab/ui';

export default {
  name: 'GlToggleVuex',
  components: {
    GlToggle,
  },
  props: {
    stateProperty: {
      type: String,
      required: true,
    },
    storeModule: {
      type: String,
      required: false,
      default: null,
    },
    setAction: {
      type: String,
      required: false,
      default() {
        return `set${this.stateProperty.charAt(0).toUpperCase()}${this.stateProperty.slice(1)}`;
      },
    },
  },
  computed: {
    value: {
      get() {
        const { state } = this.$store;
        const { stateProperty, storeModule } = this;
        return storeModule ? state[storeModule][stateProperty] : state[stateProperty];
      },
      set(value) {
        const { stateProperty, storeModule, setAction } = this;
        const action = storeModule ? `${storeModule}/${setAction}` : setAction;
        this.$store.dispatch(action, { key: stateProperty, value });
      },
    },
  },
};
</script>

<template>
  <gl-toggle v-model="value">
    <slot v-bind="{ value }"></slot>
  </gl-toggle>
</template>
