<script>
import { s__ } from '../../locale';

export default {
  props: {
    change: {
      type: Function,
      required: true,
    },
    pageInfo: {
      type: Object,
      required: true,
    },
  },
  computed: {
    mergedAttrs() {
      return Object.assign({}, this.$options.translations, this.$attrs);
    },
  },
  translations: {
    firstText: s__('Pagination|« First'),
    prevText: s__('Pagination|Prev'),
    nextText: s__('Pagination|Next'),
    lastText: s__('Pagination|Last »'),
  },
};
</script>

<template>
  <gl-pagination
    v-bind="mergedAttrs"
    :change="change"
    :page="pageInfo.page"
    :per-page="pageInfo.perPage"
    :total-rows="pageInfo.total"
    class="gl-pagination"
  />
</template>
