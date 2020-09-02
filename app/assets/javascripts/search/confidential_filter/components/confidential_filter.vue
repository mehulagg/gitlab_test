<script>
import { GlDropdown, GlDropdownItem, GlDropdownDivider } from '@gitlab/ui';
import { FILTER_STATES, FILTER_HEADER, FILTER_TEXT } from '../constants';
import { setUrlParams, visitUrl } from '~/lib/utils/url_utility';

export default {
  name: 'ConfidentialFilter',
  components: {
    GlDropdown,
    GlDropdownItem,
    GlDropdownDivider,
  },
  props: {
    scope: {
      type: String,
      required: true,
    },
    confidential: {
      type: String,
      required: false,
      default: FILTER_STATES.ANY.value,
      validator: v => Object.values(FILTER_STATES).some(({ value }) => value === v),
    },
  },
  computed: {
    selectedFilterText() {
      let filterText = FILTER_TEXT;
      if (this.selectedFilter === FILTER_STATES.CONFIDENTIAL.value) {
        filterText = FILTER_STATES.CONFIDENTIAL.label;
      } else if (this.selectedFilter === FILTER_STATES.NOT_CONFIDENTIAL.value) {
        filterText = FILTER_STATES.NOT_CONFIDENTIAL.label;
      }
      return filterText;
    },
    selectedFilter: {
      get() {
        return this.confidential;
      },
      set(value) {
        let confidential = value;
        if (value === FILTER_STATES.ANY.value) {
          confidential = null;
        }

        visitUrl(setUrlParams({ confidential }));
      },
    },
  },
  methods: {
    isFilterSelected(filter) {
      return filter === this.selectedFilter;
    },
    handleFilterChange(confidential) {
      this.selectedFilter = confidential;
    },
  },
  filterStates: FILTER_STATES,
  filterHeader: FILTER_HEADER,
  filtersArray: Object.values(FILTER_STATES),
};
</script>

<template>
  <gl-dropdown
    v-if="scope === 'issues'"
    :text="selectedFilterText"
    class="col-sm-3 gl-pt-4 gl-pl-0"
  >
    <header class="gl-text-center gl-font-weight-bold gl-font-lg">
      {{ $options.filterHeader }}
    </header>
    <gl-dropdown-divider />
    <gl-dropdown-item
      v-for="filter in $options.filtersArray"
      :key="filter.value"
      :is-check-item="true"
      :is-checked="isFilterSelected(filter.value)"
      :class="{
        'gl-border-b-solid gl-border-b-gray-100 gl-border-b-1 gl-pb-2! gl-mb-2':
          filter === $options.filterStates.ANY,
      }"
      @click="handleFilterChange(filter.value)"
    >
      {{ filter.label }}
    </gl-dropdown-item>
  </gl-dropdown>
</template>
