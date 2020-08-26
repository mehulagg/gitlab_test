<script>
import { mapState, mapGetters, mapMutations, mapActions } from 'vuex';
import EpicsSelect from 'ee/vue_shared/components/sidebar/epics_select/base.vue';
import { placeholderEpic } from 'ee/vue_shared/constants';
import { __ } from '~/locale';
import issueSetEpic from '../../queries/issue_set_epic.mutation.graphql';
import BoardSidebarItem from './board_sidebar_item.vue';
import { UPDATE_ISSUE_BY_ID } from '~/boards/stores/mutation_types';

export default {
  components: {
    BoardSidebarItem,
    EpicsSelect,
  },
  data() {
    return {
      searchTerm: '',
      selectedEpic: placeholderEpic,
      loading: false,
      searchResults: [],
      isEditing: false,
    };
  },
  computed: {
    ...mapState(['epics', 'endpoints']),
    ...mapGetters({ issue: 'getActiveIssue' }),
    storedEpic() {
      return this.epics.find(epic => epic.id === this.issue.epic?.id);
    },
    dropdownText() {
      return this.storedEpic?.title ?? __('No epic');
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
        this.selectedEpic = selectedIssue.epic;
      },
      immediate: true,
    },
  },
  methods: {
    ...mapMutations({ updateIssueById: UPDATE_ISSUE_BY_ID }),
    ...mapActions(['fetchEpicsSwimlanes']),
    setEditState(isExpanded) {
      this.isEditing = isExpanded;
    },
    async handleEditClick() {
      await this.$nextTick();
      this.$refs.epicSelect.handleEditClick();
    },
    async setEpic(selectedEpic) {
      this.loading = true;
      this.searchTerm = '';

      this.$refs.sidebarItem.collapse();

      if (!selectedEpic?.id) {
        this.updateIssueById({ issueId: this.issue.id, prop: 'epic', value: null });
        this.loading = false;
        return;
      }

      const { data, errors } = await this.$apollo.mutate({
        mutation: issueSetEpic,
        variables: {
          input: {
            epicId: `gid://gitlab/Epic/${selectedEpic.id}`,
            iid: String(this.issue.iid),
            projectPath: this.projectPath,
          },
        },
      });

      if (errors) {
        console.error(errors);
        this.selectedEpic = this.issue.epic;
        this.loading = false;

        return;
      }

      const { epic } = data.issueSetEpic.issue;
      this.selectedEpic = epic;
      this.updateIssueById({ issueId: this.issue.id, prop: 'epic', value: epic });
      await this.fetchEpicsSwimlanes(false);
      this.loading = false;
    },
  },
};
</script>

<template>
  <board-sidebar-item
    ref="sidebarItem"
    :title="__('Epic')"
    :loading="loading"
    :can-update="true"
    @open="handleEditClick"
    @changed="setEditState"
  >
    <template #collapsed>
      <a v-if="storedEpic" class="gl-text-gray-900! gl-font-weight-bold" href="#">
        {{ storedEpic && storedEpic.title }}
      </a>
    </template>
    <template>
      <epics-select
      ref="epicSelect"
        :group-id="28"
        :can-edit="true"
        :issue-id="0"
        :epic-issue-id="0"
        :initial-epic="storedEpic || {}"
        :initial-epic-loading="false"
        variant="standalone"
        :show-header="false"
        @onEpicSelect="setEpic"
      />
    </template>
  </board-sidebar-item>
</template>
