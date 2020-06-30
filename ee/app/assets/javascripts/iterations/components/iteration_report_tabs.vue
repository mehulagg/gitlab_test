<script>
import {
  GlAlert,
  GlAvatar,
  GlBadge,
  GlLink,
  GlPagination,
  GlTab,
  GlTabs,
  GlTable,
  GlTooltipDirective,
} from '@gitlab/ui';
import { __ } from '~/locale';
import { getParameterByName } from '~/lib/utils/common_utils';
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
      thClass: 'w-30p',
      tdClass: 'table-col d-flex align-items-center d-sm-table-cell',
    },
    {
      key: 'status',
      label: __('Status'),
      thClass: 'w-30p',
      tdClass: 'table-col d-flex align-items-center d-sm-table-cell',
      class: 'text-truncate',
    },
    {
      key: 'assignees',
      label: __('Assignees'),
      class: 'text-right',
      thClass: 'w-30p',
      tdClass: 'table-col d-flex align-items-center d-sm-table-cell',
    },
  ],
  components: {
    GlAlert,
    GlAvatar,
    GlBadge,
    GlLink,
    GlPagination,
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
      page:
        getParameterByName('page', window.location.href) !== null
          ? toNumber(getParameterByName('page'))
          : 1,
    };
  },
  computed: {
    totalItems() {
      return this.unstartedIssues.length + this.ongoingIssues.length + this.completedIssues.length;
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
      return this.issues.filter(issue => issue.state === 'closed');
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
    onPaginate() {},
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
        ><gl-badge class="ml-2" variant="neutral">{{ totalItems }}</gl-badge>
      </template>

      <gl-table :items="issues" :fields="$options.fields" :show-empty="true">
        <template #cell(title)="{ item: { iid, title, webUrl } }">
          <div class="text-truncate">
            <gl-link class="gl-text-gray-900 gl-font-weight-bold" :href="webUrl">{{
              title
            }}</gl-link>
            <!-- TODO: add references.relative (project name) -->
            <div class="gl-text-secondary">#{{ iid }}</div>
          </div>
        </template>

        <template #cell(status)="{ item: { state, assignees } }">
          <span class="gl-w-6 flex-shrink-0">{{ issueState(state, assignees.length) }}</span>
        </template>

        <template #cell(assignees)="{ item: { assignees } }">
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
      </gl-table>
      <div class="mt-3">
        <gl-pagination
          v-if="totalItems"
          :value="page"
          :per-page="20"
          :total-items="totalItems"
          class="justify-content-center"
          @input="onPaginate"
        />
      </div>
    </gl-tab>
  </gl-tabs>
</template>
