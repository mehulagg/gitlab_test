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
  data() {
    return {};
  },
  computed: {
    isUserSignedIn() {
      return Boolean(gon.current_user_id);
    },
  },
  methods: {
    toggleSidebar() {
      this.$emit('toggle-sidebar');
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
      <sidebar-header
        :sidebar-collapsed="sidebarCollapsed"
        :is-user-signed-in="isUserSignedIn"
        @toggle-sidebar="toggleSidebar"
      />
      <sidebar-todo
        v-if="sidebarCollapsed && isUserSignedIn"
        :sidebar-collapsed="sidebarCollapsed"
        :is-user-signed-in="isUserSignedIn"
      />
      <sidebar-status :project-path="projectPath" :alert="alert" @toggle-sidebar="toggleSidebar" />
      <sidebar-severity :severity="alert.severity" />
      <!-- TODO: Remove after adding extra attribute blocks to sidebar -->
      <div class="block"></div>
    </div>
  </aside>
</template>
