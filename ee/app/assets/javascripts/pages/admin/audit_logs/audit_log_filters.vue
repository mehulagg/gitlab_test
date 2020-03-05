<script>
import {
  GlButton,
  GlDaterangePicker,
  GlFilteredSearch,
  GlIcon,
  GlSorting,
  GlSortingItem,
} from '@gitlab/ui';
import { objectToQuery, visitUrl, mergeUrlParams } from '~/lib/utils/url_utility';

import { FILTER_TOKENS, SORT_FIELDS, SORT_ORDER } from './constants';

export default {
  name: 'AuditLogFilter',
  components: {
    GlButton,
    GlDaterangePicker,
    GlFilteredSearch,
    GlIcon,
    GlSorting,
    GlSortingItem,
  },
  data() {
    return {
      searchTerms: [],
      sortOrder: 'created_desc',
      startDate: '',
      endDate: '',
    };
  },
  computed: {
    selectedSortOrder() {
      const {
        sortOrder,
        $options: { sortOptions },
      } = this;

      if (!sortOrder) {
        return sortOptions[0].text;
      }

      return sortOptions.filter(sortOption => sortOption.key === sortOrder)[0].text;
    },
    isAscending() {
      return this.sortOrder === SORT_ORDER.ascending;
    },
  },
  methods: {
    parseSearchTerms(terms) {
      return terms
        .filter(({ value }) => Boolean(value))
        .map(({ value, type }) => ({ [type]: value }));
    },
    parseSearchData(terms) {
      // ?sort=created_desc&entity_type=User&entity_id=1&created_after=2020-03-02&created_before=2020-03-03
      return this.parseSearchTerms(terms).map(e => {
        if (e.user_id) {
          return { entity_id: e.user_id, entity_type: 'User' };
        }

        if (e.group_id) {
          return { entity_id: e.group_id, entity_type: 'Group' };
        }

        if (e.project_id) {
          return { entity_id: e.project_id, entity_type: 'Project' };
        }

        return e;
      });
    },
    handleSearchSubmit(searchData) {
      console.log(searchData);
      const data = this.parseSearchData(searchData);
      console.log(data);
      const query = data.map(e => objectToQuery(e).toString()).join('&');
      const merged = Object.assign(...data);

      //visitUrl(mergeUrlParams(merged, window.location.href));
    },
    selectSortOrder() {
      if (this.sortOrder === SORT_ORDER.ascending) {
        this.sortOrder = SORT_ORDER.descending;
      } else {
        this.sortOrder = SORT_ORDER.ascending;
      }
    },
    handleDateRange(dates) {
      this.startDate = dates.startDate;
      this.endDate = dates.endDate;
    },
    submitForm() {},
  },
  filterTokens: FILTER_TOKENS,
  sortOptions: SORT_FIELDS,
};
</script>

<template>
  <div class="d-flex justify-content-between">
    <gl-filtered-search
      class="audit-controls__search"
      v-model="searchTerms"
      :available-tokens="$options.filterTokens"
      @submit="handleSearchSubmit"
    />

    <div class="audit-controls__filters d-flex">
      <gl-daterange-picker class="d-flex" @input="handleDateRange" />

      <input type="hidden" name="sort" :value="sortOrder" />
      <div class="btn-toolbar audit-controls__sorting">
        <div class="btn-group">
          <gl-sorting
            :text="selectedSortOrder"
            :is-ascending="isAscending"
            @sortDirectionChange="selectSortOrder"
          >
            <gl-sorting-item>{{ selectedSortOrder }}</gl-sorting-item>
          </gl-sorting>
        </div>

        <!--<gl-button v-gl-tooltip href="" :title="s__('AuditLogs|Export as CSV')">
        <gl-icon name="export" />
      </gl-button>-->
      </div>
    </div>
  </div>
</template>
