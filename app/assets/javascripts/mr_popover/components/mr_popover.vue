<script>
import { GlPopover, GlSkeletonLoading } from '@gitlab/ui';
import Icon from '../../vue_shared/components/icon.vue';
import CiIcon from '../../vue_shared/components/ci_icon.vue';
import timeagoMixin from '../../vue_shared/mixins/timeago';
import query from '../queries/merge_request.graphql';

export default {
  name: 'MRPopover',
  components: {
    GlPopover,
    GlSkeletonLoading,
    Icon,
    CiIcon,
  },
  mixins: [timeagoMixin],
  props: {
    target: {
      type: HTMLAnchorElement,
      required: true,
    },
    projectPath: {
      type: String,
      required: true,
    },
    mergeRequestIID: {
      type: String,
      required: true,
    },
    mergeRequestTitle: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      mergeRequest: {},
    };
  },
  computed: {
    formattedTime() {
      return this.timeFormated(this.mergeRequest.createdAt);
    },
    statusBoxClass() {
      switch (this.mergeRequest.state) {
        case 'merged':
          return 'status-box-mr-merged';
        case 'closed':
          return 'status-box-closed';
        default:
          return 'status-box-open';
      }
    },
  },
  apollo: {
    mergeRequest: {
      query,
      update: data => data.project.mergeRequest,
      variables() {
        const { projectPath, mergeRequestIID } = this;

        return {
          projectPath,
          mergeRequestIID,
        };
      },
    },
  },
};
</script>

<template>
  <gl-popover class="mr-popover" :target="target" boundary="viewport" placement="top" show>
    <div>
      <div v-if="$apollo.loading">
        <gl-skeleton-loading :lines="1" class="animation-container-small mt-1" />
      </div>
      <div
        v-else-if="Object.keys(mergeRequest).length > 0"
        class="d-flex-center justify-content-between"
      >
        <div>
          <div :class="`issuable-status-box status-box ${statusBoxClass}`">
            {{ mergeRequest.stateHumanName }}
          </div>
          <span class="text-secondary">Opened <time v-text="formattedTime"></time></span>
        </div>
        <ci-icon
          v-if="mergeRequest.ciStatus"
          :status="{
            group: mergeRequest.ciStatus,
            icon: `status_${mergeRequest.ciStatus}`,
          }"
        />
      </div>
      <h5>{{ mergeRequestTitle }}</h5>
      <div class="text-secondary">{{ projectPath }}</div>
    </div>
  </gl-popover>
</template>
