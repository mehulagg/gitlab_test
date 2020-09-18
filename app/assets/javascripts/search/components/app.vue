<script>
import { mapState } from 'vuex';
import SearchForm from './search_form.vue';
import ScopeSelector from './scope_selector.vue';
import SearchFilters from './search_filters.vue';
import SearchResults from './search_results.vue';
import SearchLoading from './search_loading.vue';
import SearchEmptyState from './search_empty_state.vue';

export default {
  name: 'GlobalSearchApp',
  components: {
    SearchForm,
    ScopeSelector,
    SearchFilters,
    SearchResults,
    SearchLoading,
    SearchEmptyState,
  },
  props: {
    searchEmptySvgPath: {
      type: String,
      required: true,
    },
  },
  computed: {
    ...mapState(['isLoading', 'results']),
    hasResults() {
      return this.results && this.results.length > 0;
    },
  },
};
</script>

<template>
  <article>
    <search-form />
    <scope-selector />
    <search-filters />
    <section v-if="!isLoading">
      <search-results v-if="hasResults" />
      <search-empty-state v-if="!hasResults" :search-empty-svg-path="searchEmptySvgPath" />
    </section>
    <search-loading v-if="isLoading" />
  </article>
</template>
