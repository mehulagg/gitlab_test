<script>
import { GlBadge, GlLoadingIcon, GlEmptyState } from '@gitlab/ui';
import dateFormat from 'dateformat';
import { __ } from '~/locale';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import query from '../queries/group_iteration.query.graphql';

export default {
  components: {
    GlBadge,
    GlLoadingIcon,
    GlEmptyState,
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
      update(data, errors) {
        if (errors) {
          return {};
        }

        const iteration = data.group.iterations.nodes[0] || {};

        return {
          iteration,
        };
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
      group: {
        iteration: {},
      },
    };
  },
  computed: {
    iteration() {
      return this.group.iteration;
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
  },
};
</script>

<template>
  <div>
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
    </template>
  </div>
</template>
