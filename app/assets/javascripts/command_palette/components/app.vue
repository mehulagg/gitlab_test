<script>
import {
  GlFilteredSearchToken,
  GlFilteredSearchSuggestion,
  GlLoadingIcon,
  GlFilteredSearch,
} from '@gitlab/ui';
import CommandToken from './command_token.vue';
import { __ } from '~/locale';
import eventHub from '../event_hub';

import Api from '~/api';

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
      availableTokens: [],
    };
  },

  mounted() {
    console.log(__('command palette mounted'));
    this.registerKeyEventListener();
    eventHub.$on('registerCommands', this.registerCommands);
    eventHub.$on('assignees', value => console.log('eventHubbin', value));
  },
  beforeDestroy() {
    this.removeKeyEventListerner();
  },
  methods: {
    registerCommands(commands) {
      console.log(__('registering commands'));
      this.availableTokens = this.availableTokens.concat(commands);
    },
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
      actions.map(action => eventHub.$emit(action.type, action.value.data));
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
