<script>
import { GlLoadingIcon, GlButton } from '@gitlab/ui';
import Api from 'ee/api';
import { CancelToken } from 'axios';
import SplitButton from 'ee/vue_shared/security_reports/components/split_button.vue';
import axios from '~/lib/utils/axios_utils';
import download from '~/lib/utils/downloader';
import { redirectTo } from '~/lib/utils/url_utility';
import { deprecatedCreateFlash as createFlash } from '~/flash';
import { s__ } from '~/locale';
import UsersCache from '~/lib/utils/users_cache';
import ResolutionAlert from './resolution_alert.vue';
import VulnerabilityStateDropdown from './vulnerability_state_dropdown.vue';
import StatusDescription from './status_description.vue';
import { VULNERABILITY_STATE_OBJECTS, FEEDBACK_TYPES, HEADER_ACTION_BUTTONS } from '../constants';

export default {
  name: 'VulnerabilityHeader',

  components: {
    GlLoadingIcon,
    GlButton,
    ResolutionAlert,
    VulnerabilityStateDropdown,
    SplitButton,
    StatusDescription,
  },

  props: {
    initialVulnerability: {
      type: Object,
      required: true,
    },
  },

  data() {
    return {
      isProcessingAction: false,
      isLoadingVulnerability: false,
      isLoadingUser: false,
      // Spread operator because the header could modify the `project`
      // prop leading to an error in the footer component.
      vulnerability: { ...this.initialVulnerability },
      user: undefined,
      refreshVulnerabilitySource: undefined,
    };
  },

  computed: {
    actionButtons() {
      const buttons = [];

      if (this.canCreateMergeRequest) {
        buttons.push(HEADER_ACTION_BUTTONS.mergeRequestCreation);
      }

      if (this.canDownloadPatch) {
        buttons.push(HEADER_ACTION_BUTTONS.patchDownload);
      }

      return buttons;
    },
    canDownloadPatch() {
      return (
        this.vulnerability.state !== VULNERABILITY_STATE_OBJECTS.resolved.state &&
        !this.vulnerability.hasMr &&
        this.hasRemediation
      );
    },
    hasIssue() {
      return Boolean(this.vulnerability.issue_feedback?.issue_iid);
    },
    hasRemediation() {
      const { remediations } = this.vulnerability;
      return Boolean(remediations && remediations[0]?.diff?.length > 0);
    },
    canCreateMergeRequest() {
      return (
        !this.vulnerability.merge_request_feedback?.merge_request_path &&
        Boolean(this.vulnerability.create_mr_url) &&
        this.hasRemediation
      );
    },
    statusBoxStyle() {
      // Get the badge variant based on the vulnerability state, defaulting to 'expired'.
      return VULNERABILITY_STATE_OBJECTS[this.vulnerability.state]?.statusBoxStyle || 'expired';
    },
    showResolutionAlert() {
      return (
        this.vulnerability.resolved_on_default_branch &&
        this.vulnerability.state !== VULNERABILITY_STATE_OBJECTS.resolved.state
      );
    },
  },

  watch: {
    'vulnerability.state': {
      immediate: true,
      handler(state) {
        const id = this.vulnerability[`${state}_by_id`];

        if (id === undefined) return; // Don't do anything if there's no ID.

        this.isLoadingUser = true;

        UsersCache.retrieveById(id)
          .then(userData => {
            this.user = userData;
          })
          .catch(() => {
            createFlash(s__('VulnerabilityManagement|Something went wrong, could not get user.'));
          })
          .finally(() => {
            this.isLoadingUser = false;
          });
      },
    },
  },

  methods: {
    triggerClick(action) {
      const fn = this[action];
      if (typeof fn === 'function') fn();
    },
    changeVulnerabilityState(newState) {
      this.isLoadingVulnerability = true;

      Api.changeVulnerabilityState(this.vulnerability.id, newState)
        .then(({ data }) => {
          Object.assign(this.vulnerability, data);
          this.$emit('vulnerability-state-change');
        })
        .catch(() => {
          createFlash(
            s__(
              'VulnerabilityManagement|Something went wrong, could not update vulnerability state.',
            ),
          );
        })
        .finally(() => {
          this.isLoadingVulnerability = false;
        });
    },
    createMergeRequest() {
      this.isProcessingAction = true;

      const {
        report_type: category,
        pipeline: { sourceBranch },
        project_fingerprint: projectFingerprint,
      } = this.vulnerability;

      axios
        .post(this.vulnerability.create_mr_url, {
          vulnerability_feedback: {
            feedback_type: FEEDBACK_TYPES.MERGE_REQUEST,
            category,
            project_fingerprint: projectFingerprint,
            vulnerability_data: {
              ...this.vulnerability,
              category,
              target_branch: sourceBranch,
            },
          },
        })
        .then(({ data: { merge_request_path } }) => {
          redirectTo(merge_request_path);
        })
        .catch(() => {
          this.isProcessingAction = false;
          createFlash(
            s__('ciReport|There was an error creating the merge request. Please try again.'),
          );
        });
    },
    downloadPatch() {
      download({
        fileData: this.vulnerability.remediations[0].diff,
        fileName: `remediation.patch`,
      });
    },
    refreshVulnerability() {
      this.isLoadingVulnerability = true;

      // Cancel any pending API requests.
      if (this.refreshVulnerabilitySource) {
        this.refreshVulnerabilitySource.cancel();
      }

      this.refreshVulnerabilitySource = CancelToken.source();

      Api.fetchVulnerability(this.vulnerability.id, {
        cancelToken: this.refreshVulnerabilitySource.token,
      })
        .then(({ data }) => {
          Object.assign(this.vulnerability, data);
        })
        .catch(e => {
          // Don't show an error message if the request was cancelled through the cancel token.
          if (!axios.isCancel(e)) {
            createFlash(
              s__(
                'VulnerabilityManagement|Something went wrong while trying to refresh the vulnerability. Please try again later.',
              ),
            );
          }
        })
        .finally(() => {
          this.isLoadingVulnerability = false;
          this.refreshVulnerabilitySource = undefined;
        });
    },
  },
};
</script>

<template>
  <div data-qa-selector="vulnerability_header">
    <resolution-alert
      v-if="showResolutionAlert"
      :vulnerability-id="vulnerability.id"
      :default-branch-name="vulnerability.project_default_branch"
    />
    <div class="detail-page-header">
      <div class="detail-page-header-body align-items-center">
        <gl-loading-icon v-if="isLoadingVulnerability" class="mr-2" />
        <span
          v-else
          ref="badge"
          :class="
            `text-capitalize align-self-center issuable-status-box status-box status-box-${statusBoxStyle}`
          "
        >
          {{ vulnerability.state }}
        </span>

        <status-description
          class="issuable-meta"
          :vulnerability="vulnerability"
          :user="user"
          :is-loading-vulnerability="isLoadingVulnerability"
          :is-loading-user="isLoadingUser"
        />
      </div>

      <div class="detail-page-header-actions align-items-center">
        <label class="mb-0 mx-2">{{ __('Status') }}</label>
        <gl-loading-icon v-if="isLoadingVulnerability" class="d-inline" />
        <vulnerability-state-dropdown
          v-else
          :initial-state="vulnerability.state"
          @change="changeVulnerabilityState"
        />
        <split-button
          v-if="actionButtons.length > 1"
          :buttons="actionButtons"
          :disabled="isProcessingAction"
          class="js-split-button"
          @createMergeRequest="createMergeRequest"
          @downloadPatch="downloadPatch"
        />
        <gl-button
          v-else-if="actionButtons.length > 0"
          class="ml-2"
          variant="success"
          category="secondary"
          :loading="isProcessingAction"
          @click="triggerClick(actionButtons[0].action)"
        >
          {{ actionButtons[0].name }}
        </gl-button>
      </div>
    </div>
  </div>
</template>
