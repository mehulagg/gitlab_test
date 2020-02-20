<script>
import { GlTooltipDirective } from '@gitlab/ui';
import { __, s__ } from '~/locale';
import Icon from '~/vue_shared/components/icon.vue';
import LoadingButton from '~/vue_shared/components/loading_button.vue';
import { REDEPLOYING } from './constants';

export default {
  name: 'DeploymentRedeployButton',
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
    redeploy: {
      type: Function,
      required: true,
    },
  },
  computed: {
    actionInProgressTooltip() {
      switch (this.actionInProgress) {
        case REDEPLOYING:
          return __('This environment is being re-deployed');
        case null:
          return '';
        default:
          return __('Deploying this environment is currently not possible as another action is in progress');
      }
    },
    isLoading() {
      return this.actionInProgress === REDEPLOYING;
    },
  },
  redeployText: s__('MrManualDeploy|Re-deploy'),
};
</script>

<template>
  <span v-gl-tooltip :title="actionInProgressTooltip" class="d-inline-block" tabindex="0">
    <loading-button
      :loading="isLoading"
      :disabled="isActionInProgress"
      container-class="btn btn-default btn-sm inline prepend-left-4"
      @click="redeploy"
    >
      <span class="d-inline-flex align-items-baseline">
        <icon name="repeat" />
        <span>{{ $options.redeployText }}</span>
      </span>
    </loading-button>
  </span>
</template>
