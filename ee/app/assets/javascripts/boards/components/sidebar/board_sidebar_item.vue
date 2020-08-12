<script>
import { GlButton, GlLoadingIcon } from '@gitlab/ui';

export default {
  components: { GlButton, GlLoadingIcon },
  props: {
    title: {
      type: String,
      required: true,
    },
    canUpdate: {
      type: Boolean,
      required: true,
    },
    loading: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  data() {
    return {
      expanded: false,
    };
  },
  mounted() {
    document.addEventListener('click', this.collapse);
  },
  destroyed() {
    document.removeEventListener('click', this.collapse);
  },
  methods: {
    expand() {
      if (this.expanded) {
        return;
      }

      this.expanded = true;
      this.$emit('open');
    },
    collapse() {
      if (!this.expanded) {
        return;
      }

      this.expanded = false;
      this.$emit('closed');
    }
  },
};
</script>

<template>
  <div @click.stop>
    <div class="gl-display-flex gl-justify-content-space-between gl-mb-3">
      <span class="gl-vertical-align-middle">
        {{ title }}
        <gl-loading-icon v-if="loading" inline class="gl-ml-2" />
      </span>
      <gl-button v-if="canUpdate" variant="link" class="gl-text-gray-900!" @click="expand()">
        {{ __('Edit') }}
      </gl-button>
    </div>
    <div v-show="!expanded" class="gl-text-gray-400">
      <slot name="collapsed">{{ __('None') }}</slot>
    </div>
    <slot v-if="expanded"></slot>
  </div>
</template>
