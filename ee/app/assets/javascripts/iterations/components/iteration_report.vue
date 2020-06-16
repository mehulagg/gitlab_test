<script>
import {
  GlAlert,
  GlAvatar,
  GlBadge,
  GlCard,
  GlLabel,
  GlLink,
  GlLoadingIcon,
  GlEmptyState,
  GlTab,
  GlTabs,
  GlTooltipDirective,
} from '@gitlab/ui';
import dateFormat from 'dateformat';
import { __ } from '~/locale';
import { isScopedLabel } from '~/lib/utils/common_utils';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import query from '../queries/group_iteration.query.graphql';

export default {
  isScopedLabel,
  components: {
    GlAlert,
    GlAvatar,
    GlBadge,
    GlCard,
    GlLink,
    GlLabel,
    GlLoadingIcon,
    GlEmptyState,
    GlTab,
    GlTabs,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  apollo: {
    group: {
      query,
      variables() {
        return {
          groupPath: this.groupPath,
          id: getIdFromGraphQLId(this.iterationId),
        };
      },
      update(data) {
        const iteration = data?.group?.iterations?.nodes[0] || {};

        return {
          iteration,
          issues: data.group.issues.nodes.map(issue => ({
            ...issue,
            labels: issue?.labels?.nodes || [],
            assignees: issue?.assignees?.nodes || [],
          })),
        };
      },
      error(err) {
        this.error = err.message;
      },
    },
  },
  filters: {
    date: value => {
      if (!value) return '';
      const date = new Date(value);
      return dateFormat(date, 'mmm d, yyyy', true);
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
    canEdit: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  data() {
    return {
      error: '',
      group: {
        iteration: {},
      },
    };
  },
  computed: {
    iteration() {
      return this.group.iteration;
    },
    issues() {
      return this.group.issues;
    },
    hasIteration() {
      return !this.$apollo.queries.group.loading && this.iteration?.title;
    },
    status() {
      switch (this.iteration.state) {
        case 'closed':
          return {
            text: __('Closed'),
            variant: 'danger',
          };
        case 'expired':
          return { text: __('Past due'), variant: 'warning' };
        case 'upcoming':
          return { text: __('Upcoming'), variant: 'neutral' };
        default:
          return { text: __('Open'), variant: 'success' };
      }
    },
    groupedIssues() {
      return [
        {
          title: __('Unstarted issues (open and unassigned)'),
          issues: this.issues.filter(issue => {
            return issue.state === 'opened' && issue.assignees.length === 0;
          }),
        },
        {
          title: __('Ongoing issues (open and assigned)'),
          issues: this.issues.filter(issue => {
            return issue.state === 'opened' && issue.assignees.length > 0;
          }),
        },
        {
          title: __('Completed issues (closed)'),
          issues: this.issues.filter(issue => {
            return issue.state === 'closed';
          }),
        },
      ];
    },
  },
};
</script>

<template>
  <div>
    <gl-alert v-if="error" variant="danger" @dismiss="error = ''">
      {{ error }}
    </gl-alert>
    <gl-loading-icon v-if="$apollo.queries.group.loading" class="py-5" size="lg" />
    <gl-empty-state
      v-else-if="!hasIteration"
      :title="__('Could not find iteration')"
      :compact="false"
    />
    <template v-else>
      <div
        ref="topbar"
        class="gl-display-flex gl-justify-items-center gl-align-items-center gl-py-3 gl-border-1 gl-border-b-solid gl-border-gray-200"
      >
        <gl-badge :variant="status.variant">
          {{ status.text }}
        </gl-badge>
        <span class="gl-ml-4"
          >{{ iteration.startDate | date }} – {{ iteration.dueDate | date }}</span
        >
      </div>
      <h3 ref="title" class="page-title">{{ iteration.title }}</h3>
      <div ref="description" v-html="iteration.description"></div>
      <gl-tabs v-if="issues">
        <gl-tab title="Issues" class="row milestone-content gl-display-flex!">
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
  </div>
</template>
