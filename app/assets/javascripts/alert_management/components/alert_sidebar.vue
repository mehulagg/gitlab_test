<script>
import SidebarHeader from './sidebar/sidebar_header.vue';
import SidebarTodo from './sidebar/sidebar_todo.vue';
import SidebarStatus from './sidebar/sidebar_status.vue';
import SidebarSeverity from './sidebar/sidebar_severity.vue';

export default {
  components: {
    SidebarHeader,
    SidebarTodo,
    SidebarStatus,
    SidebarSeverity,
  },
  props: {
    sidebarCollapsed: {
      type: Boolean,
      required: true,
    },
    projectPath: {
      type: String,
      required: true,
    },
    alert: {
      type: Object,
      required: true,
    },
  },
  methods: {
    toggleSidebar() {
      this.$emit('toggle-sidebar');
    },
    handleAlertSidebarError(errorMessage) {
      this.$emit('alert-sidebar-error', errorMessage);
    },
  },
};
</script>

<template>
  <aside
    :class="{
      'right-sidebar-expanded': !sidebarCollapsed,
      'right-sidebar-collapsed': sidebarCollapsed,
    }"
    class="right-sidebar alert-sidebar"
  >
    <div class="issuable-sidebar js-issuable-update">
      <sidebar-header :sidebar-collapsed="sidebarCollapsed" @toggle-sidebar="toggleSidebar" />
      <sidebar-todo v-if="sidebarCollapsed" :sidebar-collapsed="sidebarCollapsed" />
      <sidebar-status
        :project-path="projectPath"
        :alert="alert"
        @toggle-sidebar="toggleSidebar"
        @alert-sidebar-error="handleAlertSidebarError"
      />
      <sidebar-severity :alert="alert" @alert-sidebar-error="handleAlertSidebarError" />
      <!-- TODO: Remove after adding extra attribute blocks to sidebar -->
      <div class="block"></div>
    </div>
  </aside>
</template>
