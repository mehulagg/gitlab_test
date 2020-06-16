<script>
import {
  GlAvatar,
  GlBadge,
  GlCard,
  GlLabel,
  GlLink,
  GlTab,
  GlTabs,
  GlTable,
  GlTooltipDirective,
} from '@gitlab/ui';
import { __ } from '~/locale';
import { isScopedLabel } from '~/lib/utils/common_utils';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import query from '../queries/iteration_issues.query.graphql';

export default {
  fields: [
    {
      key: 'title',
      label: __('Title'),
    },
    { key: 'status', label: __('Status') },
    { key: 'assignees', label: __('Assignees') },
  ],
  isScopedLabel,
  components: {
    GlAvatar,
    GlBadge,
    GlCard,
    GlLink,
    GlLabel,
    GlTab,
    GlTabs,
    GlTable,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  apollo: {
    issues: {
      query,
      variables() {
        return {
          groupPath: this.groupPath,
          id: getIdFromGraphQLId(this.iterationId),
        };
      },
      update(data) {
        const issues = data?.group?.issues?.nodes || [];

        return issues.map(issue => ({
          ...issue,
          labels: issue?.labels?.nodes || [],
          assignees: issue?.assignees?.nodes || [],
        }));
      },
      error(err) {
        this.error = err.message;
      },
    },
  },
  props: {
    groupPath: {
      type: String,
      required: true,
    },
    iterationId: {
      type: String,
      required: true,
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

    unstartedIssues() {
      return this.issues.filter(issue => {
        return issue.state === 'opened' && issue.assignees.length === 0;
      });
    },
    ongoingIssues() {
      return this.issues.filter(issue => {
        return issue.state === 'opened' && issue.assignees.length > 0;
      });
    },
    completedIssues() {
      return this.issues.filter(issue => {
        return issue.state === 'opened' && issue.assignees.length > 0;
      });
    },
  },
};
</script>

<template>
  <gl-tabs>
    <gl-tab title="Issues">
      <template #title>
        <span>{{ __('Issues') }}</span
        ><gl-badge class="ml-2" variant="neutral">{{ totalIssues }}</gl-badge>
      </template>

      <gl-table :fields="$options.fields" :items="issues" stacked="sm" show-empty> </gl-table>
      <ul class="content-list issuable-list">
        <li v-for="issue in issues" :key="issue.id">
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
    </gl-tab>
  </gl-tabs>
</template>
