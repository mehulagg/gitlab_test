<script>
import {
  GlAlert,
  GlAvatar,
  GlBadge,
  GlLink,
  GlPaginatedList,
  GlTab,
  GlTabs,
  GlTable,
  GlTooltipDirective,
} from '@gitlab/ui';
import { __ } from '~/locale';
import { isScopedLabel } from '~/lib/utils/common_utils';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import query from '../queries/iteration_issues.query.graphql';

const states = {
  opened: 'opened',
  closed: 'closed',
};

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
    GlAlert,
    GlAvatar,
    GlBadge,
    GlLink,
    GlPaginatedList,
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
        this.error = err.message || __('Error loading issues');
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
    return {
      error: '',
      currentPage: 0,
    };
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
  methods: {
    issueState(state, assigneeCount) {
      if (state === states.opened && assigneeCount === 0) {
        return __('Open');
      }
      if (state === states.opened && assigneeCount > 0) {
        return __('In progress');
      }
      return __('Closed');
    },
  },
};
</script>

<template>
  <gl-tabs>
    <gl-alert v-if="error" variant="danger" @dismiss="error = ''">
      {{ error }}
    </gl-alert>
    <gl-tab title="Issues">
      <template #title>
        <span>{{ __('Issues') }}</span
        ><gl-badge class="ml-2" variant="neutral">{{ totalIssues }}</gl-badge>
      </template>

      <gl-paginated-list
        :list="issues"
        :filterable="false"
        filter="title"
        :per-page="2"
        :current-page="currentPage"
      >
        <template #header>
          <div class="gl-display-none gl-display-sm-flex gl-justify-items-center">
            <div>
              {{ __('Title') }}
            </div>
            <div class="gl-w-12 gl-ml-auto">
              {{ __('Status') }}
            </div>
            <div class="gl-w-12">
              {{ __('Assignees') }}
            </div>
          </div>
        </template>
        <template #default="{ listItem: { iid, title, webUrl, state, assignees } }">
          <div class="text-truncate">
            <gl-link class="gl-text-gray-900 gl-font-weight-bold" :href="webUrl">{{
              title
            }}</gl-link>
            <!-- TODO: add references.relative (project name) -->
            <div class="gl-text-secondary">#{{ iid }}</div>
          </div>
          <span class="gl-w-6">{{ issueState(state, assignees.length) }}</span>
          <span class="assignee-icon gl-w-6">
            <span
              v-for="assignee in assignees"
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
        </template>
      </gl-paginated-list>
    </gl-tab>
  </gl-tabs>
</template>
