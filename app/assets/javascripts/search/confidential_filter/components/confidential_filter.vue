<script>
import { GlDropdown, GlDropdownItem, GlDropdownDivider } from '@gitlab/ui';
import {
  FILTER_STATES,
  FILTER_HEADER,
  FILTER_TEXT,
  FILTER_STATES_BY_SCOPE,
  SCOPES,
} from '../constants';
import { setUrlParams, visitUrl } from '~/lib/utils/url_utility';

const FILTERS_ARRAY = Object.values(FILTER_STATES);

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
      validator: v => FILTERS_ARRAY.some(({ value }) => value === v),
    },
  },
  computed: {
    selectedFilterText() {
      const filter = FILTERS_ARRAY.find(({ value }) => value === this.selectedFilter);
      if (!filter || filter === FILTER_STATES.ANY) {
        return FILTER_TEXT;
      }

      return filter.label;
    },
    selectedFilter: {
      get() {
        if (FILTERS_ARRAY.some(({ value }) => value === this.confidential)) {
          return this.confidential;
        }
        return FILTER_STATES.ANY.value;
      },
      set(confidential) {
        visitUrl(setUrlParams({ confidential }));
      },
    },
    showDropdown() {
      return Object.values(SCOPES).includes(this.scope);
    },
  },
  methods: {
    dropDownItemClass(filter) {
      return {
        'gl-border-b-solid gl-border-b-gray-100 gl-border-b-1 gl-pb-2! gl-mb-0':
          filter === FILTER_STATES.ANY,
      };
    },
    isFilterSelected(filter) {
      return filter === this.selectedFilter;
    },
    handleFilterChange(confidential) {
      this.selectedFilter = confidential;
    },
  },
  filterStates: FILTER_STATES,
  filterHeader: FILTER_HEADER,
  filtersByScope: FILTER_STATES_BY_SCOPE,
};
</script>

<template>
  <gl-dropdown
    v-if="showDropdown"
    :text="selectedFilterText"
    class="col-3 gl-pt-4 gl-pl-0 gl-pr-0"
    menu-class="w-100 gl-pl-0"
  >
    <header class="gl-text-center gl-font-weight-bold gl-font-lg">
      {{ $options.filterHeader }}
    </header>
    <gl-dropdown-divider />
    <gl-dropdown-item
      v-for="filter in $options.filtersByScope[scope]"
      :key="filter.value"
      :is-check-item="true"
      :is-checked="isFilterSelected(filter.value)"
      :class="dropDownItemClass(filter)"
      @click="handleFilterChange(filter.value)"
    >
      {{ filter.label }}
    </gl-dropdown-item>
  </gl-dropdown>
</template>
