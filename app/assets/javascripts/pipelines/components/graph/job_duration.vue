<script>
import { __, sprintf } from '~/locale';
import { GlProgressBar, GlPopover } from '@gitlab/ui';
import { timeIntervalInWords } from '~/lib/utils/datetime_utility';
import { roundOffFloat } from '~/lib/utils/common_utils';

export default {
  components: {
    GlProgressBar,
    GlPopover,
  },
  props: {
    duration: {
      type: Number,
      required: false,
      default: null,
    },
    pipelineDuration: {
      type: Number,
      required: false,
      default: null,
    },
  },
  computed: {
    durationInWords() {
      return timeIntervalInWords(this.duration);
    },
    percentageInWords() {
      return sprintf(__(`%{percentage} % of pipeline`), { percentage: this.percentageOfPipeline });
    },
    percentageOfPipeline() {
      return roundOffFloat((this.duration / this.pipelineDuration) * 100, 1);
    },
  },
};
</script>
<template>
  <div class="job-duration">
    <gl-progress-bar
      ref="progressBar"
      :value="percentageOfPipeline"
      variant="info"
      class="pipeline-percentage"
    />
    <gl-popover
      :target="() => $refs.progressBar"
      placement="bottom"
      triggers="hover focus"
      :title="percentageInWords"
      :content="durationInWords"
    />
  </div>
</template>
