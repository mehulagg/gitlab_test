<script>
import PaginationLinks from '~/vue_shared/components/pagination_links.vue';
import eventHub from '../event_hub';
import { getParameterByName } from '../../lib/utils/common_utils';

export default {
  components: {
    PaginationLinks,
  },
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
  computed: {
    paginate() {
      return this.pageInfo.page
        && this.pageInfo.total > this.pageInfo.perPage;
    },
  },
  methods: {
    change(page) {
      const filterGroupsParam = getParameterByName('filter_groups');
      const sortParam = getParameterByName('sort');
      const archivedParam = getParameterByName('archived');
      eventHub.$emit('fetchPage', page, filterGroupsParam, sortParam, archivedParam);
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
    <template
      v-else
    >
      <group-folder
        :groups="groups"
      />
      <pagination-links
        v-if="paginate"
        :change="change"
        :page-info="pageInfo"
        class="d-flex justify-content-center prepend-top-default"
      />
    </template>
  </div>
</template>
