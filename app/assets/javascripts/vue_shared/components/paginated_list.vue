<script>
import { s__ } from '~/locale';
import PaginationLinks from '~/vue_shared/components/pagination_links.vue';
import { GlSearchBoxByType } from '@gitlab/ui/dist/index';

export default {
  name: 'PaginatedList',
  components: {
    PaginationLinks,
    GlSearchBoxByType,
  },
  props: {
    list: {
      type: Array,
      required: true,
    },
    perPage: {
      type: Number,
      required: false,
      default: 10,
    },
    page: {
      type: Number,
      required: false,
      default: 1,
    },
    filterable: {
      type: Boolean,
      required: false,
      default: true,
    },
    filterKey: {
      type: String,
      required: false,
      default: 'id',
    },
    emptyMessage: {
      type: String,
      required: false,
      default: s__('PaginatedList|There are currently no items in this list.'),
    },
    emptySearchMessage: {
      type: String,
      required: false,
      default: s__('PaginatedList|Sorry, your filter produced no results.'),
    },
  },
  data() {
    return {
      pageIndex: this.page,
      queryStr: '',
      filterEnabled: true,
    };
  },
  computed: {
    canFilter() {
      // Filter enabled via a prop, but filter will be disabled within the component if there is a key exception
      return this.filterable && this.filterEnabled;
    },
    filteredList() {
      return this.computeFilteredList();
    },
    paginatedList() {
      const offset = (this.pageIndex - 1) * this.perPage;
      return this.filteredList.slice(offset, offset + this.perPage);
    },
    pageInfo() {
      return { perPage: this.perPage, total: this.filterTotal, page: this.pageIndex };
    },
    total() {
      return this.list.length;
    },
    filterTotal() {
      return this.filteredList.length;
    },
    zeroTotal() {
      return this.total === 0;
    },
    zeroSearchResults() {
      return this.total > 0 && this.filterTotal === 0;
    },
  },
  methods: {
    change(page) {
      this.pageIndex = page;
    },
    query(queryStr) {
      this.pageIndex = 1;
      this.queryStr = queryStr;
    },
    computeFilteredList() {
      try {
        return this.list.filter(listItem =>
          listItem[this.filterKey].toLowerCase().includes(this.queryStr.toLowerCase()),
        );
      } catch (err) {
        this.filterEnabled = false;
        return this.list;
      }
    },
  },
};
</script>

<template>
  <div>
    <div class="row-content-block second-block d-sm-flex justify-content-between">
      <slot name="header"></slot>
      <gl-search-box-by-type v-if="canFilter" class="mt-3 mt-sm-0" @input="query" />
    </div>

    <slot name="subheader"></slot>

    <ul class="list-group list-group-flush list-unstyled">
      <li v-for="listItem in paginatedList" :key="listItem[filterKey]">
        <slot :listItem="listItem"></slot>
      </li>
    </ul>

    <pagination-links
      :change="change"
      :page-info="pageInfo"
      class="d-flex justify-content-center prepend-top-default"
    />
    <div v-if="zeroTotal" class="bs-callout bs-callout-warning mt-3 empty-message">
      {{ emptyMessage }}
    </div>
    <div v-if="zeroSearchResults" class="bs-callout bs-callout-warning mt-3 empty-search">
      {{ emptySearchMessage }}
    </div>
  </div>
</template>
