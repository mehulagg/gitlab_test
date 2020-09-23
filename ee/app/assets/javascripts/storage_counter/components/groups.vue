<script>
import GroupFolder from './group_folder.vue';
import PaginationLinks from '~/vue_shared/components/pagination_links.vue';

export default {
  components: {
    GroupFolder,
  },
  props: {
    hierarchy: {
      type: Object,
      required: false,
      default: () => ({}),
    },
  },
  computed: {
    group() {
      const groupName = Object.keys(this.hierarchy)[0];
      return this.hierarchy[groupName];
    },
  },
};
</script>

<template>
  <div>
    <group-folder :group="group" />
    <!-- <pagination-links
      :change="change"
      :page-info="pageInfo"
      class="d-flex justify-content-center gl-mt-3"
    /> -->
  </div>
</template>
