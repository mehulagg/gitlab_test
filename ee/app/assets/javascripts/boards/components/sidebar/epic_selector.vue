<script>
import BoardSidebarItem from './board_sidebar_item.vue';
import { GlDropdown, GlDropdownHeader, GlSearchBoxByType } from '@gitlab/ui';

export default {
  components: { BoardSidebarItem, GlDropdown, GlDropdownHeader, GlSearchBoxByType },
  data() {
    return {
      searchTerm: '',
      selectedEpic: null,
      loading: false,
      epics: [],
    };
  },
  methods: {
    fetchEpics() {
      // TODO: Load epics
    },
    handleClose() {
      this.loading = true;
      setTimeout(() => {
        this.loading = false;
      }, 1000);
    },
  },
};
</script>

<template>
  <board-sidebar-item
    :title="__('Epic')"
    :loading="loading"
    :can-update="true"
    @open="fetchEpics"
    @closed="handleClose"
  >
    <template #collapsed>
      <strong v-if="selectedEpic">{{ selectedEpic.title }}</strong>
    </template>
    <template>
      <gl-dropdown :text="__('No epic')" block>
        <gl-dropdown-header>{{ __('Assign epic') }}</gl-dropdown-header>
        <gl-search-box-by-type v-model.trim="searchTerm" class="m-2" />
        <gl-dropdown-item v-for="epic in epics" :key="epic.id">
          {{ epic.title }}
        </gl-dropdown-item>
        <div v-show="!epics.length" class="text-secondary p-2">{{ __('No matches found') }}</div>
      </gl-dropdown>
    </template>
  </board-sidebar-item>
</template>
