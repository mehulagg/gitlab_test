<script>
/* === WARNING ===
 * This file will be removed pending the removal of the `approval_rules` feature flag.
 *
 * If a new feature needs to be added, please please make changes in the `./multiple_rule`
 * directory (see the feature issue https://gitlab.com/gitlab-org/gitlab-ee/issues/1979).
 *
 * Follow along via this issue: https://gitlab.com/gitlab-org/gitlab-ee/issues/10685.
 */

import { n__, s__, sprintf } from '~/locale';
import Flash, { hideFlash } from '~/flash';
import Icon from '~/vue_shared/components/icon.vue';
import MrWidgetAuthor from '~/vue_merge_request_widget/components/mr_widget_author.vue';
import tooltip from '~/vue_shared/directives/tooltip';
import eventHub from '~/vue_merge_request_widget/event_hub';
import { APPROVE_ERROR, OPTIONAL_CAN_APPROVE, OPTIONAL, APPROVAL_PASSWORD_INVALID } from '../messages';

export default {
  name: 'ApprovalsBody',
  components: {
    MrWidgetAuthor,
    Icon,
  },
  directives: {
    tooltip,
  },
  props: {
    mr: {
      type: Object,
      required: true,
    },
    service: {
      type: Object,
      required: true,
    },
    approvedBy: {
      type: Array,
      required: false,
      default: () => [],
    },
    approvalsOptional: {
      type: Boolean,
      required: false,
      default: false,
    },
    approvalsLeft: {
      type: Number,
      required: false,
      default: 0,
    },
    userCanApprove: {
      type: Boolean,
      required: false,
      default: false,
    },
    forceAuthForApproval: {
      type: Boolean,
      required: false,
      default: false
    },
    userHasApproved: {
      type: Boolean,
      required: false,
      default: false,
    },
    suggestedApprovers: {
      type: Array,
      required: false,
      default: () => [],
    },
  },
  data() {
    return {
      approving: false,
      approvalPassword: null,
      showApprovePasswordPrompt: false,
    };
  },
  computed: {
    approvalsRequiredStringified() {
      if (this.approvalsOptional) {
        if (this.userCanApprove) {
          return OPTIONAL_CAN_APPROVE;
        }

        return OPTIONAL;
      }

      if (this.approvalsLeft === 0) {
        return this.userCanApprove
          ? s__('mrWidget|Merge request approved; you can approve additionally')
          : s__('mrWidget|Merge request approved');
      }

      if (this.suggestedApprovers.length >= 1) {
        return sprintf(
          n__(
            'mrWidget|Requires 1 more approval by',
            'mrWidget|Requires %d more approvals by',
            this.approvalsLeft,
          ),
        );
      }

      return sprintf(
        n__(
          'mrWidget|Requires 1 more approval',
          'mrWidget|Requires %d more approvals',
          this.approvalsLeft,
        ),
      );
    },
    approveButtonText() {
      let approveButtonText = s__('mrWidget|Approve');
      if (this.approvalsLeft <= 0) {
        approveButtonText = s__('mrWidget|Add approval');
      }
      return approveButtonText;
    },
    confirmButtonText() {
        return s__('mrWidget|Confirm')
    },
    cancelButtonText() {
        return s__('mrWidget|Cancel')
    },
    approveButtonClass() {
      return {
        'btn-inverted': this.showApproveButton && this.approvalsLeft <= 0,
      };
    },
    showApprovalDocLink() {
      return this.approvalsOptional && this.showApproveButton;
    },
    showApproveButton() {
      return this.userCanApprove && !this.userHasApproved && this.mr.isOpen;
    },
    showSuggestedApprovers() {
      return this.approvalsLeft > 0 && this.suggestedApprovers && this.suggestedApprovers.length;
    },
    approvalPasswordPlaceholder() {
      return s__('Password');
    },
  },
  methods: {
    approveMergeRequest() {
        if(!this.forceAuthForApproval) {
            this.doApproveMergeRequest();
            return;
        }
        this.showApprovePasswordPrompt = true;
    },
    cancelApprovePasswordPrompt() {
        this.showApprovePasswordPrompt = false;
    },
    doApproveMergeRequest() {
      const flashEl = document.querySelector('.flash-alert');
      if(flashEl != null) {
          hideFlash(flashEl);
      }
      this.approving = true;
      this.service
        .approveMergeRequest(this.approvalPassword)
        .then(data => {
          this.mr.setApprovals(data);
          eventHub.$emit('MRWidgetUpdateRequested');
          this.approving = false;
          this.showApprovePasswordPrompt = false;
        })
        .catch((error) => {
          if(error && error.response && error.response.status === 403) {
            Flash(APPROVAL_PASSWORD_INVALID);
          }
          else {
            Flash(APPROVE_ERROR);
          }
          this.approving = false;
        });
    },
  },
};
</script>

<template>
  <div class="approvals-body space-children">
    <span v-if="showApproveButton && !showApprovePasswordPrompt" class="approvals-approve-button-wrap">
      <button
        :disabled="approving"
        :class="approveButtonClass"
        class="btn btn-primary btn-sm approve-btn"
        @click="approveMergeRequest"
      >
        <i v-if="approving" class="fa fa-spinner fa-spin" aria-hidden="true"></i>
        {{ approveButtonText }}
      </button>
    </span>
    <div v-if="showApprovePasswordPrompt" class="force-approval-auth form-row align-items-center">
        <div class="col-auto">
            <input
                id="force-auth-password"
                v-model="approvalPassword"
                type="password"
                class="form-control"
                autocomplete="new-password"
                :placeholder="approvalPasswordPlaceholder" />
        </div>
        <div class="col-auto">
            <button
                :disabled="approving"
                :class="approveButtonClass"
                class="btn btn-primary btn-sm approve-btn"
                @click="doApproveMergeRequest"
            >
                <i v-if="approving" class="fa fa-spinner fa-spin" aria-hidden="true"></i>
                {{ confirmButtonText }}
            </button>
        </div>
        <div class="col-auto">
            <button
                :disabled="approving"
                class="btn btn-default btn-sm"
                @click="cancelApprovePasswordPrompt"
            >
                {{ cancelButtonText }}
            </button>
        </div>
    </div>
    <span v-show="!showApprovePasswordPrompt" :class="approvalsOptional ? 'text-muted' : 'bold'" class="approvals-required-text" >
      {{ approvalsRequiredStringified }}
      <a
        v-if="showApprovalDocLink"
        v-tooltip
        :href="mr.approvalsHelpPath"
        :title="__('About this feature')"
        data-placement="bottom"
        target="_blank"
        rel="noopener noreferrer nofollow"
        data-container="body"
      >
        <icon name="question-o" />
      </a>
      <span v-if="showSuggestedApprovers">
        <mr-widget-author
          v-for="approver in suggestedApprovers"
          :key="approver.username"
          :author="approver"
          :show-author-name="false"
          :show-author-tooltip="true"
        />
      </span>
    </span>
  </div>
</template>
