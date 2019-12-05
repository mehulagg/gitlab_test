<script>
import { GlLoadingIcon, GlTooltipDirective, GlButton } from '@gitlab/ui';
import CiStatus from '~/vue_shared/components/ci_icon.vue';
import { __ } from '~/locale';

export default {
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  components: {
    CiStatus,
    GlLoadingIcon,
    GlButton,
  },
  props: {
    pipeline: {
      type: Object,
      required: true,
    },
  },
  computed: {
    tooltipText() {
      return `${this.projectName} - ${this.pipelineStatus.label}`;
    },
    buttonId() {
      return `js-linked-pipeline-${this.pipeline.id}`;
    },
    pipelineStatus() {
      return this.pipeline.details.status;
    },
    projectName() {
      return this.pipeline.project.name;
    },
    parent() {
      return this.pipeline.parent;
    },
    child() {
      return this.pipeline.child;
    },
    label() {
      return this.parent ? __('Parent') : __('Child');
    },
  },
  methods: {
    onClickLinkedPipeline() {
      this.$root.$emit('bv::hide::tooltip', this.buttonId);
      this.$emit('pipelineClicked');
    },
  },
};
</script>

<template>
  <li class="linked-pipeline build">
    <div class="curve"></div>
    <gl-button
      :id="buttonId"
      v-gl-tooltip
      :title="tooltipText"
      class="js-linked-pipeline-content linked-pipeline-content"
      data-qa-selector="linked_pipeline_button"
      :class="`js-pipeline-expand-${pipeline.id}`"
      @click="onClickLinkedPipeline"
    >
      <gl-loading-icon v-if="pipeline.isLoading" class="js-linked-pipeline-loading d-inline" />
      <ci-status
        v-else
        :status="pipelineStatus"
        css-classes="position-top-0"
        class="js-linked-pipeline-status"
      />
      <span class="str-truncated align-bottom"> {{ projectName }} &#8226; #{{ pipeline.id }} </span>
      <div v-if="parent || child" class="parent-child-label-container">
        <span class="badge badge-primary">{{ label }}</span>
      </div>
    </gl-button>
  </li>
</template>
