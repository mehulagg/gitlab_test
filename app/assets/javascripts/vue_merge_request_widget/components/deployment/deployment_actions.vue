<script>
import { __, s__ } from '~/locale';
import { visitUrl } from '~/lib/utils/url_utility';
import createFlash from '~/flash';
import MRWidgetService from '../../services/mr_widget_service';
import DeploymentInfo from './deployment_info.vue';
import DeploymentManualDeployButton from './deployment_manual_deploy_button.vue';
import DeploymentRedeployButton from './deployment_redeploy_button.vue';
import DeploymentStopButton from './deployment_stop_button.vue';
import DeploymentViewButton from './deployment_view_button.vue';
import { MANUAL_DEPLOY, RUNNING, FAILED, SUCCESS, STOPPING, DEPLOYING, REDEPLOYING } from './constants';

export default {
  // name: 'Deployment' is a false positive: https://gitlab.com/gitlab-org/frontend/eslint-plugin-i18n/issues/26#possible-false-positives
  // eslint-disable-next-line @gitlab/i18n/no-non-i18n-strings
  name: 'DeploymentActions',
  components: {
    DeploymentManualDeployButton,
    DeploymentRedeployButton,
    DeploymentStopButton,
    DeploymentViewButton,
  },
  props: {
    computedDeploymentStatus: {
      type: String,
      required: true,
    },
    deployment: {
      type: Object,
      required: true,
    },
    showVisualReviewApp: {
      type: Boolean,
      required: false,
      default: false,
    },
    visualReviewAppMeta: {
      type: Object,
      required: false,
      default: () => ({
        sourceProjectId: '',
        sourceProjectPath: '',
        mergeRequestId: '',
        appUrl: '',
      }),
    },
  },
  data() {
    return {
      actionInProgress: null,
    };
  },
  computed: {
    appButtonText() {
      return {
        text: this.isCurrent ? s__('Review App|View app') : s__('Review App|View latest app'),
        tooltip: this.isCurrent
          ? ''
          : __('View the latest successful deployment to this environment'),
      };
    },
    canBeManuallyDeployed() {
      return this.computedDeploymentStatus === MANUAL_DEPLOY && Boolean(this.playPath);
    },
    canBeManuallyRedeployed() {
      return this.computedDeploymentStatus === FAILED && Boolean(this.redeployPath);
    },
    hasExternalUrls() {
      return Boolean(this.deployment.external_url && this.deployment.external_url_formatted);
    },
    isCurrent() {
      return this.computedDeploymentStatus === SUCCESS;
    },
    isActionInProgress() {
      return Boolean(this.computedDeploymentStatus.status === RUNNING || this.actionInProgress);
    },
    playPath() {
      return this.deployment.details?.playable_build?.play_path;
    },
    redeployPath() {
      return this.deployment.details?.playable_build?.retry_path;
    },
    stopUrl() {
      return this.deployment.stop_url;
    }
  },
  actionsConfiguration: {
    [STOPPING]: {
      actionName: STOPPING,
      confirmMessage: __('Are you sure you want to stop this environment?'),
      errorMessage: __('Something went wrong while stopping this environment. Please try again.'),
    },
    [DEPLOYING]: {
      actionName: DEPLOYING,
      confirmMessage: __('Are you sure you want to deploy this environment?'),
      errorMessage: __('Something went wrong while deploying this environment. Please try again.'),
    },
    [REDEPLOYING]: {
      actionName: REDEPLOYING,
      confirmMessage: __('Are you sure you want to re-deploy this environment?'),
      errorMessage: __('Something went wrong while deploying this environment. Please try again.'),
    },
  },
  methods: {
    executeAction(endpoint, { actionName, confirmMessage, errorMessage }, reset) {
      const isConfirmed = confirm(confirmMessage); // eslint-disable-line

      if (isConfirmed) {
        this.actionInProgress = actionName;

        MRWidgetService.executeInlineAction(endpoint)
          .then(res => res.data)
          .then(data => {
            this.actionInProgress = null;

            if (data.redirect_url) {
              visitUrl(data.redirect_url);
            }
          })
          .catch(() => {
            createFlash(errorMessage);
            this.actionInProgress = null;
          });
      }
    },
    stopEnvironment() {
      this.executeAction(this.stopUrl, this.$options.actionsConfiguration[STOPPING])
    },
    deployManually() {
      this.executeAction(this.playPath, this.$options.actionsConfiguration[DEPLOYING])
    },
    redeploy() {
      this.executeAction(this.redeployPath, this.$options.actionsConfiguration[REDEPLOYING])
    },
  },
};
</script>

<template>
  <div>
    <div>
      <deployment-manual-deploy-button
        v-if="canBeManuallyDeployed"
        :is-action-in-progress="isActionInProgress"
        :deploy-manually="deployManually"
        :action-in-progress="actionInProgress"
      />
      <deployment-redeploy-button
        v-if="canBeManuallyRedeployed"
        :is-action-in-progress="isActionInProgress"
        :redeploy="redeploy"
        :action-in-progress="actionInProgress"
      />
      <deployment-view-button
        v-if="hasExternalUrls"
        :app-button-text="appButtonText"
        :deployment="deployment"
        :show-visual-review-app="showVisualReviewApp"
        :visual-review-app-metadata="visualReviewAppMeta"
      />
      <deployment-stop-button
        v-if="stopUrl"
        :is-action-in-progress="isActionInProgress"
        :stop-environment="stopEnvironment"
        :action-in-progress="actionInProgress"
        :computed-deployment-status="computedDeploymentStatus"
      />
    </div>
  </div>
</template>
