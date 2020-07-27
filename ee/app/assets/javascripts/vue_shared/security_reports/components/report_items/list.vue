<script>
import ReportItemLabel from './label.vue';
import ReportItemNamedList from './named_list.vue';
import ReportItemModuleLocation from './module_location.vue';
import ReportItemHexInt from './hex_int.vue';

const tableAwareTypes = [
  "label",
];

export default {
  name: 'ReportItemList',
  components: {
    ReportItemLabel,
    ReportItemNamedList,
    ReportItemModuleLocation,
    ReportItemHexInt
  },
  props: {
    items: {
      type: Array,
      required: true
    }
  },
  computed: {
  },
};
</script>

<template>
  <table class="table report-item-table">
    <component
      v-for="item in items"
      :is="'report-item-' + item.type"
      v-if="item.type"
      v-bind="item"
    />
  </table>
</template>
