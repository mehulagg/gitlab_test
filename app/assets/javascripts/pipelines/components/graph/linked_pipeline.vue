<script>
import { GlLoadingIcon, GlTooltipDirective, GlDeprecatedButton } from '@gitlab/ui';
import CiStatus from '~/vue_shared/components/ci_icon.vue';
import { __ } from '~/locale';

export default {
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  components: {
    CiStatus,
    GlLoadingIcon,
    GlDeprecatedButton,
  },
  props: {
    pipeline: {
      type: Object,
      required: true,
    },
    projectId: {
      type: Number,
      required: true,
    },
    columnTitle: {
      type: String,
      required: true,
    },
  },
  computed: {
    tooltipText() {
      return `${this.downstreamTitle} #${this.pipeline.id} - ${this.pipelineStatus.label}
      ${__('Created by')} ${this.sourceJob}`;
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
    downstreamTitle() {
      return this.childPipeline ? __('child-pipeline') : this.pipeline.project.name;
    },
    parentPipeline() {
      // Refactor string match when BE returns Upstream/Downstream indicators
      return this.projectId === this.pipeline.project.id && this.columnTitle === __('Upstream');
    },
    childPipeline() {
      // Refactor string match when BE returns Upstream/Downstream indicators
      return this.projectId === this.pipeline.project.id && this.columnTitle === __('Downstream');
    },
    label() {
      if (this.parentPipeline) {
        return __('Parent');
      } else if (this.childPipeline) {
        return __('Child');
      }
      return __('Multi-project');
    },
    sourceJob() {
      return this.pipeline.source_job.name;
    },
  },
  methods: {
    onClickLinkedPipeline() {
      this.$root.$emit('bv::hide::tooltip', this.buttonId);
      this.$emit('pipelineClicked', this.$refs.linkedPipeline);
    },
    hideTooltips() {
      this.$root.$emit('bv::hide::tooltip');
    },
  },
};
</script>

<template>
  <li
    ref="linkedPipeline"
    class="linked-pipeline build"
    :class="{ 'child-pipeline': childPipeline }"
    data-qa-selector="child_pipeline"
  >
    <gl-deprecated-button
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
      <span class="str-truncated"> {{ downstreamTitle }} &#8226; #{{ pipeline.id }} </span>
      <div class="gl-pt-2">
        <span class="badge badge-primary" data-testid="downstream-pipeline-label">{{ label }}</span>
      </div>
    </gl-deprecated-button>
  </li>
</template>
