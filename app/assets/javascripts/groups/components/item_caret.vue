<script>
import icon from '~/vue_shared/components/icon.vue';

export default {
  components: {
    icon,
  },
  props: {
    isGroupOpen: {
      type: Boolean,
      required: true,
      default: false,
    },
  },
  computed: {
    iconClass() {
      return this.isGroupOpen ? 'chevron-down' : 'chevron-right';
    },
  },
};
</script>

<template>
  <span class="folder-caret gl-mr-2"> <icon :size="16" :name="iconClass" class="gl-text-gray-700" /> </span>
</template>
