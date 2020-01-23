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
  // eslint-disable-next-line camelcase
  colorScheme: gon?.user_color_scheme,
};
</script>

<template>
  <div
    :style="{
      left: `${position.x}px`,
      top: `${position.y + position.height}px`,
    }"
    class="popover gl-popover fade bs-popover-bottom show"
  >
    <div class="arrow"></div>
    <div v-for="(hover, index) in data.hover" :key="index" class="border-bottom">
      <pre
        :class="$options.colorScheme"
        class="border-0 bg-transparent m-0 code highlight"
        v-html="hover.value"
      ></pre>
    </div>
    <div v-if="data.definition_url" class="popover-body">
      <gl-button :href="data.definition_url" target="_blank" class="w-100">
        {{ __('Go to definition') }}
      </gl-button>
    </div>
  </div>
</template>
