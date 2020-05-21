<script>
import ToggleSidebar from '~/vue_shared/components/sidebar/toggle_sidebar.vue';

import SidebarTodo from './sidebar_todo.vue';

export default {
  components: {
    ToggleSidebar,
    SidebarTodo,
  },
  props: {
    sidebarCollapsed: {
      type: Boolean,
      required: true,
    },
  },
};
</script>

<template>
  <div class="block">
    <span class="issuable-header-text hide-collapsed float-left">{{ __('To Do') }}</span>
    <toggle-sidebar
      :collapsed="sidebarCollapsed"
      css-classes="float-right"
      @toggle="$emit('toggle-sidebar')"
    />
    <sidebar-todo v-if="!sidebarCollapsed" :sidebar-collapsed="sidebarCollapsed" />
  </div>
</template>
