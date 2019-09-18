<script>
import LinkedPipeline from './linked_pipeline.vue';

export default {
  components: {
    LinkedPipeline,
  },
  props: {
    linkedPipelines: {
      type: Array,
      required: true,
    },
    graphPosition: {
      type: String,
      required: true,
    },
  },
  computed: {
    columnClass() {
      const positionValues = {
        right: 'prepend-left-64',
        left: 'append-right-32',
      };
      return `graph-position-${this.graphPosition} ${positionValues[this.graphPosition]}`;
    },
  },
};
</script>

<template>
  <div :class="columnClass" class="stage-column linked-pipelines-column">
    <ul class="list-unstyled">
      <linked-pipeline
        v-for="(pipeline, index) in linkedPipelines"
        :key="pipeline.id"
        :class="{ active: pipeline.isExpanded }"
        :pipeline="pipeline"
        @pipelineClicked="$emit('linkedPipelineClick', pipeline, index)"
      />
    </ul>
  </div>
</template>
