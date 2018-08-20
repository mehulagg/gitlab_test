<script>
import { mergeUrlParams } from '~/lib/utils/url_utility';
import { s__ } from '../../locale';

export default {
  props: {
    groups: {
      type: Array,
      required: true,
    },
    pageInfo: {
      type: Object,
      required: true,
    },
    searchEmpty: {
      type: Boolean,
      required: true,
    },
    searchEmptyMessage: {
      type: String,
      required: true,
    },
  },
  data: () => ({
    paginationText: {
      first: s__('Pagination|« First'),
      prev: s__('Pagination|Prev'),
      next: s__('Pagination|Next'),
      last: s__('Pagination|Last »'),
    },
  }),

  methods: {
    change(page) {
      return mergeUrlParams({ page }, window.location.href);
    },
  },
};
</script>

<template>
  <div class="groups-list-tree-container">
    <div
      v-if="searchEmpty"
      class="has-no-search-results"
    >
      {{ searchEmptyMessage }}
    </div>
    <group-folder
      v-if="!searchEmpty"
      :groups="groups"
    />
    <gl-pagination
      v-if="!searchEmpty && pageInfo.totalPages > 1"
      :link-gen="change"
      :value="pageInfo.page"
      :number-of-pages="pageInfo.totalPages"
      :first-text="paginationText.first"
      :prev-text="paginationText.prev"
      :next-text="paginationText.next"
      :last-text="paginationText.last"
      class="gl-pagination d-flex justify-content-center prepend-top-default"
    />
  </div>
</template>
