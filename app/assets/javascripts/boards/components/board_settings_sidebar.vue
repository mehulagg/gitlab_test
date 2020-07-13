<script>
import { GlDrawer, GlLabel } from '@gitlab/ui';
import { mapActions, mapState } from 'vuex';
import { __ } from '~/locale';
import autofocusonshow from '~/vue_shared/directives/autofocusonshow';
// not sure if this needs ee_else_ce or something
import boardsStore from '../stores/boards_store';
import eventHub from '~/sidebar/event_hub';
import { inactiveListId } from '~/boards/constants';
import BoardDelete from '~/boards/components/board_delete';

// NOTE: need to revisit how we handle headerHeight, because we have so many different header and footer options.
export default {
  headerHeight: process.env.NODE_ENV === 'development' ? '75px' : '40px',
  listSettingsText: __('List settings'),
  label: 'label',
  labelListText: __('Label'),
  components: {
    BoardDelete,
    GlDrawer,
    GlLabel,
  },
  directives: {
    autofocusonshow,
  },
  data() {
    return {
      edit: false,
    };
  },
  computed: {
    ...mapState(['activeListId']),
    activeList() {
      /*
        Warning: Though a computed property it is not reactive because we are
        referencing a List Model class. Reactivity only applies to plain JS objects
      */
      return boardsStore.state.lists.find(({ id }) => id === this.activeListId);
    },
    isSidebarOpen() {
      return this.activeListId !== inactiveListId;
    },
    activeListLabel() {
      return this.activeList?.label;
    },
  },
  created() {
    eventHub.$on('sidebar.closeAll', this.closeSidebar);
  },
  beforeDestroy() {
    eventHub.$off('sidebar.closeAll', this.closeSidebar);
  },
  methods: {
    ...mapActions(['setActiveListId']),
    closeSidebar() {
      // TODO: this is EE only (for wip limits)
      this.edit = false;
      this.setActiveListId(inactiveListId);
    },
  },
};
</script>

<template>
  <gl-drawer
    class="js-board-settings-sidebar"
    :open="isSidebarOpen"
    :header-height="$options.headerHeight"
    @close="closeSidebar"
  >
    <template #header>{{ $options.listSettingsText }}</template>
    <template>
      <slot>
        <div class="d-flex flex-column align-items-start">
          <label class="js-list-label">{{ $options.labelListText }}</label>
          <gl-label :title="activeListLabel.title" :background-color="activeListLabel.color" />
        </div>
      </slot>
      <!-- TODO: I removed canAdminList from v-if -->
      <div>
        <board-delete
          v-if="activeListId && !activeList.preset"
          :list="activeList"
          inline-template="true"
        >
          <gl-button
            v-gl-tooltip.hover.bottom
            :block="true"
            :class="{ 'gl-display-none': activeList && !activeList.isExpanded }"
            class="board-delete"
            @click.stop="deleteBoard"
          >
            {{ s__('Boards|Remove list') }}
          </gl-button>
        </board-delete>
      </div>
    </template>
  </gl-drawer>
</template>
