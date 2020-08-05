<script>
import { GlFilteredSearchToken, GlLoadingIcon, GlFilteredSearchSuggestion } from '@gitlab/ui';
import { debounce } from 'lodash';

const DEBOUNCE_DELAY = 300;
export default {
  components: {
    GlFilteredSearchToken,
    GlFilteredSearchSuggestion,
    GlLoadingIcon,
  },
  props: {
    config: {
      type: Object,
      required: true,
    },
    value: {
      type: Object,
      required: true,
    },
  },
  methods: {
    search: debounce(function debouncedSearch({ data = '' }) {
      this.config.fetchData(data);
    }, DEBOUNCE_DELAY),
  },
};
</script>
<template>
  <gl-filtered-search-token
    :config="config"
    v-bind="{...$props, ...$attrs}"
    v-on="$listeners"
    @input="search"
  >
    <template #view="{inputValue}">
      <span>{{inputValue}}</span>
    </template>
    <template #suggestions>
      <gl-loading-icon v-if="config.isLoading" />
      <template v-else>
        <gl-filtered-search-suggestion
          v-for="suggestion in config.suggestions"
          :key="suggestion.value"
          :value="suggestion.value"
        >
          <div class="gl-display-flex"></div>
        </gl-filtered-search-suggestion>
      </template>
    </template>
  </gl-filtered-search-token>
</template>