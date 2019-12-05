<script>
import { GlButton, GlTooltipDirective } from '@gitlab/ui';
import Icon from '~/vue_shared/components/icon.vue';

export default {
  components: {
    GlButton,
    Icon,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    showAllWithoutToggle: {
      type: Boolean,
      required: true,
    },
  },
  data() {
    return {
      expanded: false,
    };
  },
  computed: {
    shouldShowButtons() {
      return this.showAllWithoutToggle || this.expanded;
    },
    shouldShowToggle() {
      return !this.showAllWithoutToggle;
    },
  },
  methods: {
    handleToggleClick() {
      this.$nextTick(() => {
        this.$root.$emit('bv::hide::tooltip');
      });

      this.expanded = !this.expanded;
    },
  },
};
</script>
<template>
  <div>
    <div class="btn-group table-action-buttons js-pipelines-actions-wrapper">
      <slot v-if="shouldShowButtons" name="action-buttons"></slot>

      <gl-button
        v-if="shouldShowToggle"
        v-gl-tooltip
        type="button"
        :title="__('Actions')"
        class="pipeline-action-button js-more-actions-toggle more-actions-toggle btn"
        @click="handleToggleClick"
      >
        <icon css-classes="icon" name="ellipsis_v" />
        <icon css-classes="icon" name="chevron-down" />
      </gl-button>
    </div>
  </div>
</template>
