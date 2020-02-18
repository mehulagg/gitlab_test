<script>
import { GlTooltipDirective } from '@gitlab/ui';
import { __, s__ } from '~/locale';
import Icon from '~/vue_shared/components/icon.vue';
import LoadingButton from '~/vue_shared/components/loading_button.vue';
import { visitUrl } from '~/lib/utils/url_utility';
import createFlash from '~/flash';
import MRWidgetService from '../../services/mr_widget_service';

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
    isDeployInProgress: {
      type: Boolean,
      required: true,
    },
    playUrl: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      isDeploying: false,
    };
  },
  computed: {
    deployInProgressTooltip() {
      return this.isDeployInProgress
        ? __('Stopping this environment is currently not possible as a deployment is in progress')
        : '';
    },
  },
  deployText: s__('MrManualDeploy|Deploy'),
  methods: {
    deployManually() {
      const msg = __('Are you sure you want to deploy this environment?');
      const isConfirmed = confirm(msg); // eslint-disable-line

      if (isConfirmed) {
        this.isDeploying = true;

        MRWidgetService.executeInlineAction(this.playUrl)
          .then(res => res.data)
          .then(data => {
            if (data.redirect_url) {
              visitUrl(data.redirect_url);
            }
          })
          .catch(() => {
            createFlash(
              __('Something went wrong while deploying this environment. Please try again.'),
            );
            this.isDeploying = false;
          });
      }
    },
  },
};
</script>

<template>
  <span v-gl-tooltip :title="deployInProgressTooltip" class="d-inline-block" tabindex="0">
    <loading-button
      :loading="isDeploying"
      :disabled="isDeployInProgress"
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
