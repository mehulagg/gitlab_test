<script>
/**
 * Renders a prevent auto-stop button.
 * Used in environments table.
 */
import { GlButton, GlTooltipDirective } from '@gitlab/ui';
import Icon from '~/vue_shared/components/icon.vue';
import { __ } from '~/locale';

export default {
  components: {
    Icon,
    GlButton,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    autoStopPath: {
      type: String,
      required: false,
      default: '',
    },
    disabled: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  computed: {
    title() {
      return __('Prevent environment from auto-stopping');
    },
  },
};
</script>
<template>
  <gl-button
    v-gl-tooltip
    :title="title"
    :aria-label="title"
    :href="autoStopPath"
    :class="{ disabled: disabled }"
  >
    <icon name="thumbtack" />
  </gl-button>
</template>
