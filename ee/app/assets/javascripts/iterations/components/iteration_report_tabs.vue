<script>
import {
  GlAvatar,
  GlBadge,
  GlCard,
  GlLabel,
  GlLink,
  GlTab,
  GlTabs,
  GlTooltipDirective,
} from '@gitlab/ui';
import { __ } from '~/locale';
import { isScopedLabel } from '~/lib/utils/common_utils';

export default {
  isScopedLabel,
  components: {
    GlAvatar,
    GlBadge,
    GlCard,
    GlLink,
    GlLabel,
    GlTab,
    GlTabs,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    unstartedIssues: {
      type: Array,
      required: false,
      default: () => [],
    },
    ongoingIssues: {
      type: Array,
      required: false,
      default: () => [],
    },
    completedIssues: {
      type: Array,
      required: false,
      default: () => [],
    },
  },
  data() {
    return {};
  },
  computed: {
    totalIssues() {
      return this.unstartedIssues.length + this.ongoingIssues.length + this.completedIssues.length;
    },

    groupedIssues() {
      return [
        {
          title: __('Unstarted issues (open and unassigned)'),
          issues: this.unstartedIssues,
        },
        {
          title: __('Ongoing issues (open and assigned)'),
          issues: this.ongoingIssues,
        },
        {
          title: __('Completed issues (closed)'),
          issues: this.completedIssues,
        },
      ];
    },
  },
};
</script>

<template>
  <gl-tabs>
    <gl-tab title="Issues" class="row milestone-content gl-display-flex!">
      <template #title>
        <span>{{ __('Issues') }}</span
        ><gl-badge class="ml-2" variant="neutral">{{ totalIssues }}</gl-badge>
      </template>
      <div v-for="g in groupedIssues" :key="g.title" class="col-sm-4">
        <gl-card header-class="gl-line-height-normal" body-class="gl-p-0">
          <template #header>
            <span>{{ g.title }}</span>
          </template>
          <template #default>
            <ul class="content-list milestone-issues-list">
              <li v-for="issue in g.issues" :key="issue.title" class="gl-p-5!">
                <gl-link :href="issue.webUrl">{{ issue.title }}</gl-link>
                <div class="issuable-detail">
                  <gl-link :href="issue.webUrl">#{{ issue.iid }}</gl-link>
                  <gl-label
                    v-for="label in issue.labels"
                    :key="label.id"
                    :background-color="label.color"
                    :title="label.title"
                    :description="label.description"
                    :scoped="$options.isScopedLabel(label)"
                    class="mr-2"
                    size="sm"
                  />
                  <span class="assignee-icon">
                    <span
                      v-for="assignee in issue.assignees"
                      :key="assignee.username"
                      v-gl-tooltip="
                        sprintf(__('Assigned to %{assigneeName}'), {
                          assigneeName: assignee.name,
                        })
                      "
                    >
                      <gl-avatar :src="assignee.avatarUrl" :size="16" />
                    </span>
                  </span>
                </div>
              </li>
            </ul>
          </template>
        </gl-card>
      </div>
    </gl-tab>
  </gl-tabs>
</template>
