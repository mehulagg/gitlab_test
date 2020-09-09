<script>
import { GlDropdown, GlDropdownItem, GlDropdownDivider } from '@gitlab/ui';
import { FILTER_STATES, FILTER_HEADER, FILTER_TEXT } from '../constants';
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
        if (FILTERS_ARRAY.some(({ value }) => value === this.confidential)) {
          return this.confidential;
        }
        return FILTER_STATES.ANY.value;
      },
      set(confidential) {
        visitUrl(setUrlParams({ confidential }));
      },
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
  filtersArray: FILTERS_ARRAY,
};
</script>

<template>
  <gl-dropdown
    v-if="scope === 'issues'"
    :text="selectedFilterText"
    class="col-3 gl-pt-4 gl-pl-0 gl-pr-0"
    menu-class="w-100 gl-pl-0"
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
      :class="dropDownItemClass(filter)"
      @click="handleFilterChange(filter.value)"
    >
      {{ filter.label }}
    </gl-dropdown-item>
  </gl-dropdown>
</template>
