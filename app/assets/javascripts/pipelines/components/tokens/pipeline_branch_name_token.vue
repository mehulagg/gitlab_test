<script>
import {
  GlFilteredSearchToken,
  GlFilteredSearchSuggestion,
  GlLoadingIcon,
  GlDropdownDivider,
} from '@gitlab/ui';
import Api from '~/api';
import { FETCH_BRANCH_ERROR_MESSAGE, FILTER_PIPELINES_SEARCH_DELAY } from '../../constants';
import createFlash from '~/flash';
import { debounce } from 'lodash';
import { __ } from '~/locale';

export default {
  staticBranch: __('master'),
  components: {
    GlFilteredSearchToken,
    GlFilteredSearchSuggestion,
    GlLoadingIcon,
    GlDropdownDivider,
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
  data() {
    return {
      branches: null,
      loading: true,
    };
  },
  created() {
    this.fetchBranches();
  },
  methods: {
    fetchBranches(searchterm) {
      Api.branches(this.config.projectId, searchterm)
        .then(({ data }) => {
          this.branches = data.map(branch => branch.name);
          this.loading = false;
        })
        .catch(err => {
          createFlash(FETCH_BRANCH_ERROR_MESSAGE);
          this.loading = false;
          throw err;
        });
    },
    searchBranches: debounce(function debounceSearch({ data }) {
      this.fetchBranches(data);
    }, FILTER_PIPELINES_SEARCH_DELAY),
  },
};
</script>

<template>
  <gl-filtered-search-token
    :config="config"
    v-bind="{ ...$props, ...$attrs }"
    v-on="$listeners"
    @input="searchBranches"
  >
    <template #suggestions>
      <gl-loading-icon v-if="loading" />
      <template v-else>
        <gl-filtered-search-suggestion :value="$options.staticBranch" data-testid="static">{{
          $options.staticBranch
        }}</gl-filtered-search-suggestion>
        <gl-dropdown-divider />
        <gl-filtered-search-suggestion
          v-for="(branch, index) in branches"
          :key="index"
          :value="branch"
        >
          {{ branch }}
        </gl-filtered-search-suggestion>
      </template>
    </template>
  </gl-filtered-search-token>
</template>
