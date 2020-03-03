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
    selectedProject() {
      const { value } = this;
      return !!value ? this.suggestions.find(project => project.id === parseInt(value, 10)) : {};
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
        .then(res => (this.suggestions = res.data))
        .catch(() => createFlash(`Failed to find ${this.type}. Please try again.`))
        .finally(() => (this.loadingSuggestions = false));
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
      <template v-else-if="value && selectedProject.id">
        <gl-avatar
          :size="16"
          :src="selectedProject.avatar_url"
          :entity-id="selectedProject.id"
          :entity-name="selectedProject.name"
          shape="circle"
          class="mr-1"
        />
        <span>{{ selectedProject.name }}</span>
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
        <li
          class="gl-new-dropdown-item dropdown-item gl-filtered-search-suggestion"
          v-if="value && suggestions.length === 0"
        >
          <span class="dropdown-item">No results found</span>
        </li>
        <gl-filtered-search-suggestion
          v-for="(project, idx) in suggestions"
          :key="idx"
          :value="project.id.toString()"
        >
          <div class="avatar-container s40">
            <gl-avatar
              :size="32"
              :src="project.avatar_url"
              :entity-id="project.id"
              :entity-name="project.name"
              :alt="`${project.name}'s avatar`"
              shape="circle"
              class="w-100 h-100 lazy"
            />
          </div>
          <div class="d-flex flex-column">
            <span>{{ project.name }}</span>
            <span class="dropdown-light-content">{{ project.name_with_namespace }}</span>
          </div>
        </gl-filtered-search-suggestion>
      </template>
    </template>
  </gl-filtered-search-binary-token>
</template>
