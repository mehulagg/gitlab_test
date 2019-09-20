<script>
import ActionComponent from './action_component.vue';
import ciIcon from '../../../vue_shared/components/ci_icon.vue';
import { GlTooltipDirective, GlLink } from '@gitlab/ui';
import { sprintf } from '~/locale';
import delayedJobMixin from '~/jobs/mixins/delayed_job_mixin';

/**
 * Renders the badge for the pipeline graph and the job's dropdown.
 *
 * The following object should be provided as `job`:
 *
 * {
 *   "id": 4256,
 *   "name": "test",
 *   "status": {
 *     "icon": "status_success",
 *     "text": "passed",
 *     "label": "passed",
 *     "group": "success",
 *     "tooltip": "passed",
 *     "details_path": "/root/ci-mock/builds/4256",
 *     "action": {
 *       "icon": "retry",
 *       "title": "Retry",
 *       "path": "/root/ci-mock/builds/4256/retry",
 *       "method": "post"
 *     }
 *   }
 * }
 */

export default {
  components: {
    ActionComponent,
    ciIcon,
    GlLink,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  mixins: [delayedJobMixin],
  props: {
    job: {
      type: Object,
      required: true,
    },
    cssClassJobName: {
      type: String,
      required: false,
      default: '',
    },
    dropdownLength: {
      type: Number,
      required: false,
      default: Infinity,
    },
  },
  computed: {
    boundary() {
      return this.dropdownLength === 1 ? 'viewport' : 'scrollParent';
    },
    status() {
      return this.job && this.job.status ? this.job.status : {};
    },

    tooltipText() {
      const textBuilder = [];
      const { name: jobName } = this.job;

      if (jobName) {
        textBuilder.push(jobName);
      }

      const { tooltip: statusTooltip } = this.status;
      if (jobName && statusTooltip) {
        textBuilder.push('-');
      }

      if (statusTooltip) {
        if (this.isDelayedJob) {
          textBuilder.push(sprintf(statusTooltip, { remainingTime: this.remainingTime }));
        } else {
          textBuilder.push(statusTooltip);
        }
      }

      return textBuilder.join(' ');
    },
    /**
     * Verifies if the provided job has an action path
     *
     * @return {Boolean}
     */
    hasAction() {
      return this.job.status && this.job.status.action && this.job.status.action.path;
    },
  },
  methods: {
    pipelineActionRequestComplete() {
      this.$emit('pipelineActionRequestComplete');
    },
  },
};
</script>
<template>
  <div class="ci-job-component">
    <component
      :is="status.has_details ? 'gl-link' : 'div'"
      v-gl-tooltip="{ boundary, placement: 'bottom' }"
      :href="status.details_path"
      :title="tooltipText"
      :class="cssClassJobName"
      class="js-pipeline-graph-job-link qa-job-link w-100 d-flex flex-row align-items-center"
    >
      <ci-icon :status="job.status" />

      <span class="ci-status-text text-truncate gl-pl-2 flex-grow-1">
        {{ job.name }}
      </span>

      <action-component
        v-if="hasAction"
        :tooltip-text="status.action.title"
        :link="status.action.path"
        :action-icon="status.action.icon"
        @pipelineActionRequestComplete="pipelineActionRequestComplete"
      />
    </component>
  </div>
</template>
