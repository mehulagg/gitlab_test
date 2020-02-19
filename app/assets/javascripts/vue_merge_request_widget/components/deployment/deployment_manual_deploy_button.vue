<script>
import { GlTooltipDirective } from '@gitlab/ui';
import { __, s__ } from '~/locale';
import Icon from '~/vue_shared/components/icon.vue';
import LoadingButton from '~/vue_shared/components/loading_button.vue';
import { DEPLOYING } from './constants';

export default {
  name: 'DeploymentManualDeployButton',
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
      default: null,
    },
    isActionInProgress: {
      type: Boolean,
      required: true,
    },
    deployManually: {
      type: Function,
      required: true,
    },
  },
  computed: {
    actionInProgressTooltip() {
      switch (this.actionInProgress) {
        case DEPLOYING:
          return __('This environment is being deployed');
        case null:
          return '';
        default:
          return __('Deploying this environment is currently not possible as another action is in progress');
      }
    },
    isLoading() {
      return this.actionInProgress === DEPLOYING;
    },
  },
  deployText: s__('MrManualDeploy|Deploy'),
};
</script>

<template>
  <span v-gl-tooltip :title="actionInProgressTooltip" class="d-inline-block" tabindex="0">
    <loading-button
      :loading="isLoading"
      :disabled="isActionInProgress"
      container-class="btn btn-default btn-sm inline prepend-left-4"
      @click="deployManually"
    >
      <span class="d-inline-flex align-items-baseline">
        <icon name="play" />
        <span>{{ $options.deployText }}</span>
      </span>
    </loading-button>
  </span>
</template>
