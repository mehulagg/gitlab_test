<script>
  import eventHub from '../event_hub';
  import { getParameterByName } from '../../lib/utils/common_utils';
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
    <group-folder
      v-if="!searchEmpty"
      :groups="groups"
    />
    <gl-pagination
      v-if="!searchEmpty"
      :change="change"
      :page-info="pageInfo"
      :first-text="paginationText.first"
      :prev-text="paginationText.prev"
      :next-text="paginationText.next"
      :last-text="paginationText.last"
      class="gl-pagination d-flex justify-content-center prepend-top-default"
    />
  </div>
</template>
