<script>
import {
  GlFilteredSearchToken,
  GlFilteredSearchSuggestion,
  GlLoadingIcon,
  GlFilteredSearch,
} from '@gitlab/ui';
import CommandToken from './command_token.vue';
import { __ } from '~/locale';
import UsersCache from '~/lib/utils/users_cache';
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
    };
  },
  computed: {
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
    submitCommand() {
      console.log('lets go');
    },
    fetchAssignees(data) {
      console.log('fetching', data);
      return UsersCache.retrieve(data)
        .then(userData => {
          this.assignees = userData;
        })
        .catch(() => {
          console.log('fetch failed');
        });
      // return Api.users(data, {}).then(data => {
      //   console.log({ data });
      // });
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