<script>
import Todo from '~/sidebar/components/todo_toggle/todo.vue';

export default {
  components: {
    Todo,
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
  <div :class="{ 'block todo': sidebarCollapsed }">
    <!-- TODO: Implement after or as part of: https://gitlab.com/gitlab-org/gitlab/-/issues/215946 -->
    <todo
      :collapsed="sidebarCollapsed"
      :issuable-id="1"
      :is-todo="false"
      :is-action-active="false"
      issuable-type="alert"
      class="disabled"
      @toggleTodo="() => {}"
    />
  </div>
</template>
