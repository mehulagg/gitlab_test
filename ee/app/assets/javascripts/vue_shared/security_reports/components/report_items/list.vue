<script>
import ReportItemLabel from './label.vue';
import ReportItemNamedList from './named_list.vue';
import ReportItemModuleLocation from './module_location.vue';
import ReportItemHexInt from './hex_int.vue';

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
  <div class="report-item-list">
    <div v-for="item in items" v-if="items">
      <component
        :is="'report-item-' + item.type"
        v-if="item.type"
        v-bind="item"
      />
    </div>
  </div>
</template>
