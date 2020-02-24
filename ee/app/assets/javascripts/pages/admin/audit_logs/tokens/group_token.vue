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
    selectedGroup() {
      const { value } = this;
      return !!value ? this.suggestions.find(group => group.id == value) : {};
    },
  },
  methods: {
    loadSuggestions(search) {
      this.loadingSuggestions = true;
      const { path, defaultPrams } = this.config;
      const params = {
        ...defaultPrams,
        search,
      };
      return axios
        .get(path, { params })
        .then(res => this.suggestions = res.data)
        .catch(() => createFlash(`Failed to find ${this.type}. Please try again.`))
        .finally(() => this.loadingSuggestions = false);
    },
  },
  watch: {
    value(search) {
      this.loadSuggestions(search);
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
      <gl-loading-icon size="sm" v-if="loadingView" class="mr-1" />
      <template v-else-if="value && selectedGroup.id">
        <gl-avatar :size="16" :src="selectedGroup.avatar_url" :entity-id="selectedGroup.id" :entity-name="selectedGroup.name" shape="circle" class="mr-1"/>
        <span>{{ selectedGroup.name }}</span>
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
          v-for="(group, idx) in suggestions"
          :key="idx"
          :value="group.id.toString()"
        >
          <div class="avatar-container s40">
            <gl-avatar
              :size="32"
              :src="group.avatar_url"
              :entity-id="group.id"
              :entity-name="group.name"
              :alt="`${group.name}'s avatar`"
              shape="circle"
              class="w-100 h-100 lazy"/>
          </div>
          <div class="d-flex flex-column">
            <span>{{ group.full_name }}</span>
            <span class="dropdown-light-content">{{ group.full_path }}</span>
          </div>
        </gl-filtered-search-suggestion>
      </template>
    </template>
  </gl-filtered-search-binary-token>
</template>
