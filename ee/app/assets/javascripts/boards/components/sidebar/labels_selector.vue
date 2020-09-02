<script>
import { mapState, mapGetters, mapMutations, mapActions } from 'vuex';
import { GlLabel } from '@gitlab/ui';
import LabelsSelectVue from '~/vue_shared/components/sidebar/labels_select_vue/labels_select_root.vue';
import { __, s__, sprintf } from '~/locale';
import BoardSidebarItem from './board_sidebar_item.vue';
import { UPDATE_ISSUE_BY_ID } from '~/boards/stores/mutation_types';

export default {
  components: {
    GlLabel,
    LabelsSelectVue,
    BoardSidebarItem,
  },
  data() {
    return {
      searchTerm: '',
      selectedLabels: [],
      loading: false,
      searchResults: [],
      isEditing: false,
    };
  },
  computed: {
    ...mapState(['endpoints']),
    ...mapGetters({ issue: 'getActiveIssue' }),
    selectedLabelsIds() {
      return this.selectedLabels.map(label => label.id);
    },
    intSelectedLabels() {
      return this.selectedLabels.map(label => ({
        ...label,
        id: Number.isNaN(Number(label.id))
          ? Number(label.id.slice(label.id.lastIndexOf('/') + 1))
          : label.id,
      }));
    },
    dropdownText() {
      const { selectedLabels: labels } = this;

      if (!labels.length) {
        return __('None');
      }

      const [firstLabel] = labels;

      if (labels.length === 1) {
        return firstLabel.title;
      }

      return sprintf(s__('LabelSelect|%{firstLabelName} +%{remainingLabelCount} more'), {
        firstLabelName: firstLabel.title,
        remainingLabelCount: labels.length - 1,
      });
    },
    fullPath() {
      return this.endpoints?.fullPath || '';
    },
    projectPath() {
      const { referencePath = '' } = this.issue;
      return referencePath.slice(0, referencePath.indexOf('#'));
    },
  },
  watch: {
    issue: {
      handler(selectedIssue = {}) {
        this.selectedLabels = [...selectedIssue.labels];
      },
      immediate: true,
    },
  },
  methods: {
    ...mapMutations({ updateIssueById: UPDATE_ISSUE_BY_ID }),
    ...mapActions(['fetchEpicsSwimlanes']),
    async handleCollapsedValueClick() {
      await this.$nextTick();
      this.$refs.labelsSelect.toggleDropdownContents();
    },
    setEditState(isExpanded) {
      this.isEditing = isExpanded;
    },
    async setLabels(labels) {
      const ids = [];
      const allLabels = [...labels, ...this.intSelectedLabels];

      const filtered = allLabels.filter(label => {
        const exists = ids.includes(label.id);
        ids.push(label.id);

        return !exists && label.set !== false;
      });

      this.updateIssueById({ issueId: this.issue.id, prop: 'labels', value: filtered });
      this.selectedLabels = filtered;
      this.$refs.sidebarItem.collapse();
    },
  },
};
</script>

<template>
  <board-sidebar-item
    ref="sidebarItem"
    :title="__('Labels')"
    :loading="loading"
    :can-update="true"
    @open="handleCollapsedValueClick"
    @close="$refs.labelsSelect.toggleDropdownContents()"
  >
    <template #collapsed>
      <gl-label
        v-for="label in issue.labels"
        :key="label.id"
        :background-color="label.color"
        :title="label.title"
        :description="label.description"
        :view-only="false"
        size="sm"
        class="gl-mr-2 gl-mb-2"
      />
    </template>
    <template>
      <labels-select-vue
        ref="labelsSelect"
        :allow-label-edit="false"
        :allow-label-create="true"
        :allow-multiselect="true"
        :allow-scoped-labels="false"
        :selected-labels="intSelectedLabels"
        labels-fetch-path="/groups/h5bp/-/labels.json?include_ancestor_groups=true&only_group_labels=true"
        labels-manage-path="/groups/h5bp/-/labels"
        labels-filter-base-path="/groups/h5bp/-/epics"
        :labels-list-title="__('Select label')"
        :dropdown-button-text="__('Choose labels')"
        variant="embedded"
        class="block labels js-labels-block gl-w-full"
        @updateSelectedLabels="setLabels"
      >
        {{ __('None') }}
      </labels-select-vue>
    </template>
  </board-sidebar-item>
</template>
