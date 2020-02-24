<script>
import {
  GlFilteredSearchBinaryToken,
  GlFilteredSearchSuggestion,
  GlDropdownDivider,
  GlLoadingIcon,
  GlAvatar,
} from '@gitlab/ui';
import createFlash from '~/flash';
import axios from '~/lib/utils/axios_utils';

export default {
  components: {
    GlFilteredSearchBinaryToken,
    GlFilteredSearchSuggestion,
    GlDropdownDivider,
    GlLoadingIcon,
    GlAvatar,
  },
  props: ['value', 'active', 'title', 'config', 'type'],
  data() {
    return {
      loadingView: false,
      loadingSuggestions: false,
      suggestions: [],
    };
  },
  computed: {
    selectedUser() {
      const { value } = this;
      if (!value) return {};
      return this.suggestions.find(user => user.username === value) || {};
    },
  },
  methods: {
    transformUsers(users) {
      return users.map(user => ({
        ...user,
        username: `@${user.username}`,
      }));
    },
    loadSuggestions(search) {
      this.loadingSuggestions = true;
      const { path, defaultPrams } = this.config;
      const params = {
        ...defaultPrams,
        search,
      };
      return axios
        .get(path, { params })
        .then(res => this.suggestions = this.transformUsers(res.data))
        .catch(() => createFlash(`Failed to find ${this.type}. Please try again.`))
        .finally(() => this.loadingSuggestions = false);
    },
  },
  watch: {
    value(search) {
      const username = !!search && search[0] === '@' ? search.substring(1) : search;
      this.loadSuggestions(username);
    },
  },
  mounted() {
    this.loadSuggestions();
  },
};
</script>

<template>
  <gl-filtered-search-binary-token :title="title" :active="active" :value="value" v-on="$listeners">
    <template #view>
      <gl-loading-icon size="sm" v-if="loadingView" class="gl-mr-2" />
      <template v-else-if="value && selectedUser.id">
        <gl-avatar :size="16" :src="selectedUser.avatar_url" :entity-id="selectedUser.id" :entity-name="selectedUser.name" shape="circle" class="mr-1"/>
        <span>{{ selectedUser.name }}</span>
      </template>
      <span v-else>
        {{ value }}
      </span>
    </template>
    <template #suggestions>
      <template v-if="loadingSuggestions">
        <gl-loading-icon />
      </template>
      <template v-else>
        <template v-if="value.length === 0">
          <gl-filtered-search-suggestion value="Any">Any</gl-filtered-search-suggestion>
          <gl-dropdown-divider v-if="suggestions.length" />
        </template>
        <li class="gl-new-dropdown-item dropdown-item gl-filtered-search-suggestion" v-if="value && suggestions.length === 0">
          <span class="dropdown-item">No results found</span>
        </li>
        <gl-filtered-search-suggestion
          v-for="(user, idx) in suggestions"
          :key="idx"
          :value="user.username"
        >
          <div class="avatar-container s40">
            <gl-avatar
              :size="32"
              :src="user.avatar_url"
              :entity-id="user.id"
              :entity-name="user.name"
              :alt="`${user.name}'s avatar`"
              shape="circle"
              class="w-100 h-100 lazy"/>
          </div>
          <div class="d-flex flex-column">
            <span>{{ user.name }}</span>
            <span class="dropdown-light-content">{{ user.username }}</span>
          </div>
        </gl-filtered-search-suggestion>
      </template>
    </template>
  </gl-filtered-search-binary-token>
</template>
