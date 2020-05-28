<script>
import { mapState, mapActions } from 'vuex';
import { GlFilteredSearch } from '@gitlab/ui';
import { __ } from '~/locale';
import MilestoneToken from '../../shared/components/tokens/milestone_token.vue';
import LabelToken from '../../shared/components/tokens/label_token.vue';
import AuthorToken from '../../shared/components/tokens/author_token.vue';
import AssigneeToken from '../../shared/components/tokens/assignee_token.vue';

export default {
  name: 'FilteredSearchComponent',
  components: {
    GlFilteredSearch,
  },
  props: {
    disabled: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  data() {
    return {
      searchTerms: [],
    };
  },
  computed: {
    ...mapState('filters', {
      milestonePath: 'milestonePath',
      labelsPath: 'labelsPath',
      milestones: state => state.milestones.data,
      milestonesLoading: state => state.milestones.isLoading,
      labels: state => state.labels.data,
      labelsLoading: state => state.labels.isLoading,
    }),
    tokens() {
      return [
        {
          icon: 'clock',
          title: __('Milestone'),
          type: 'milestone',
          token: MilestoneToken,
          milestones: this.milestones,
          unique: true,
          symbol: '%',
          isLoading: this.milestonesLoading,
        },
        {
          icon: 'labels',
          title: __('Label'),
          type: 'label',
          token: LabelToken,
          labels: this.labels,
          unique: false,
          symbol: '~',
          isLoading: this.labelsLoading,
        },
        // TODO: Is there a symbol we use for author / assignees
        {
          icon: 'pencil',
          title: __('Author'),
          type: 'author',
          token: AuthorToken,
          users: this.users,
          unique: false,
          // symbol: '~', //
          isLoading: this.usersLoading,
        },
        // {
        //   icon: 'user',
        //   title: __('Assignees'),
        //   type: 'assignees',
        //   token: AssigneeToken,
        //   users: this.users,
        //   unique: false,
        //   // symbol: '~',
        //   isLoading: this.usersLoading,
        // },
      ];
    },
  },
  created() {
    this.fetchMilestones();
    this.fetchLabels();
    this.fetchAuthors();
  },
  methods: {
    ...mapActions('filters', ['fetchMilestones', 'fetchLabels', 'fetchAuthors', 'setFilters']),
    processFilters(filters) {
      return filters.reduce((acc, token) => {
        const { type, value } = token;
        const { operator } = value;
        let tokenValue = value.data;

        // remove wrapping double quotes which were added for token values that include spaces
        if (
          (tokenValue[0] === "'" && tokenValue[tokenValue.length - 1] === "'") ||
          (tokenValue[0] === '"' && tokenValue[tokenValue.length - 1] === '"')
        ) {
          tokenValue = tokenValue.slice(1, -1);
        }

        if (!acc[type]) {
          acc[type] = [];
        }

        acc[type].push({ value: tokenValue, operator });
        return acc;
      }, {});
    },

    filteredSearchSubmit(filters) {
      const { label: labelNames, milestone } = this.processFilters(filters);
      const milestoneTitle = milestone ? milestone[0] : null;
      this.setFilters({ labelNames, milestoneTitle });
    },
  },
};
</script>

<template>
  <gl-filtered-search
    :disabled="disabled"
    :v-model="searchTerms"
    :placeholder="__('Filter results')"
    :clear-button-title="__('Clear')"
    :close-button-title="__('Close')"
    :available-tokens="tokens"
    @submit="filteredSearchSubmit"
  />
</template>
