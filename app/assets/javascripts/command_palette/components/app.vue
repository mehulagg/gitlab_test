<script>
import {
  GlFilteredSearchToken,
  GlFilteredSearchSuggestion,
  GlLoadingIcon,
  GlFilteredSearch,
} from '@gitlab/ui';
import CommandToken from './command_token.vue';
import { __ } from '~/locale';

import Api from '../../api';

export default {
  name: 'CommandPalette',
  components: {
    GlFilteredSearch,
    GlFilteredSearchToken,
    GlFilteredSearchSuggestion,
    GlLoadingIcon,
  },
  data() {
    return {
      isVisible: true, // false,
      value: [],
      assignees: null,
    };
  },
  computed: {
    commandsByType() {
      return {
        assignees: {
          callback: payload => {
            console.log(__('callback payload'), payload);
          },
        },
      };
    },
    availableTokens() {
      return [
        {
          type: 'assignees',
          title: __('Assign'),
          icon: 'user',
          token: CommandToken,
          suggestions: this.assignees,
          active: true,
          operators: [{ value: '=', description: 'is', default: 'true' }],
          isLoading: this.assigneesLoading,
          fetchData: this.fetchAssignees,
        },
      ];
    },
  },
  mounted() {
    this.registerKeyEventListener();
  },
  beforeDestroy() {
    this.removeKeyEventListerner();
  },
  methods: {
    registerKeyEventListener() {
      document.addEventListener('keydown', this.keyDown);
    },
    removeKeyEventListerner() {
      document.removeEventListener('keydown', this.keyDown);
    },
    keyDown(event) {
      if (event.keyCode === 80 && event.ctrlKey && event.altKey) {
        console.log(__('opening palette'));
        this.isVisible = true;
      }
    },
    submitCommand(submittedCommands) {
      console.log(__('lets go'));

      // iterate over array and kick off action?
      this.activeActions(submittedCommands);
    },
    activeActions(actions) {
      actions.map(action => {
        console.log(action.type);
        console.log(action.value.data);
        this.commandsByType[action.type].callback(action.value.data);
        return 'foo';
      });
    },
    fetchAssignees(data) {
      return Api.users(data, {}).then(response => {
        this.assignees = response.data;
      });
    },
  },
};
</script>

<template>
  <div v-if="isVisible" class="command-palette">
    <gl-filtered-search
      v-model="value"
      :placeholder="__('Command palette')"
      :available-tokens="availableTokens"
      @submit="submitCommand"
    />
  </div>
</template>
