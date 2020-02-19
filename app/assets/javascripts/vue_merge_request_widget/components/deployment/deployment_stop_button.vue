<script>
import { GlTooltipDirective } from '@gitlab/ui';
import { __ } from '~/locale';
import Icon from '~/vue_shared/components/icon.vue';
import LoadingButton from '~/vue_shared/components/loading_button.vue';
import { SUCCESS, STOPPING } from './constants';

export default {
  name: 'DeploymentStopButton',
  components: {
    LoadingButton,
    Icon,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    actionInProgress: {
      type: String,
      required: false,
      default: 'none'
    },
    isActionInProgress: {
      type: Boolean,
      required: true,
    },
    computedDeploymentStatus: {
      type: String,
      required: true,
    },
    stopEnvironment: {
      type: Function,
      required: true,
    },
  },
  computed: {
    actionInProgressTooltip() {
      switch (this.actionInProgress) {
        case STOPPING:
          return __('This environment is being stopped');
        case null:
          return '';
        default:
          return __('Stopping this environment is currently not possible as another action is in progress');
      }
    },
    isLoading() {
      return this.actionInProgress === STOPPING;
    },
    isDisabled() {
      return this.actionInProgress && this.computedDeploymentStatus !== SUCCESS;
    },
  },
};
</script>

<template>
  <span v-gl-tooltip :title="actionInProgressTooltip" class="d-inline-block" tabindex="0">
    <loading-button
      v-gl-tooltip
      :loading="isLoading"
      :disabled="isDisabled"
      :title="__('Stop environment')"
      container-class="js-stop-env btn btn-default btn-sm inline prepend-left-4"
      @click="stopEnvironment"
    >
      <icon name="stop" />
    </loading-button>
  </span>
</template>
