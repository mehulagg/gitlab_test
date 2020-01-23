<script>
import { GlButton } from '@gitlab/ui';

export default {
  components: {
    GlButton,
  },
  props: {
    position: {
      type: Object,
      required: false,
      default: null,
    },
    data: {
      type: Object,
      required: false,
      default: null,
    },
  },
};
</script>

<template>
  <div
    :style="{
      left: `${position.x + position.width / 2 - 12}px`,
      top: `${position.y + position.height}px`,
    }"
    class="popover gl-popover fade bs-popover-bottom show"
  >
    <div class="arrow"></div>
    <div :class="{ 'border-bottom': data.definition }">
      <pre class="border-0 bg-transparent m-0">{{ data.hover.contents[0].value }}</pre>
    </div>
    <div v-if="data.definition_url" class="popover-body">
      <gl-button :href="data.definition_url" target="_blank" class="w-100">
        {{ __('Go to definition') }}
      </gl-button>
    </div>
  </div>
</template>
