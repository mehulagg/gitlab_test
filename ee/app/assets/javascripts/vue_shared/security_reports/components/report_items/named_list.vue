<script>
import ReportItemLabel from './label.vue';
import ReportItemList from './list.vue';
import ReportItemHexInt from './hex_int.vue';
import ReportItemPlain from './plain.vue';
import ReportItemFileLocation from './file_location.vue';
import ReportItemModuleLocation from './module_location.vue';
import VulnerabilityDetail from '../vulnerability_detail.vue';

export default {
  name: 'ReportItemNamedList',
  beforeCreate() {
    this.$options.components.ReportItemList = require('./list.vue').default;
  },
  components: {
    ReportItemList,
    VulnerabilityDetail,
    ReportItemLabel,
    ReportItemModuleLocation,
    ReportItemFileLocation,
    ReportItemHexInt,
    ReportItemPlain
  },
  props: {
    items: {
      type: Object,
      required: true
    }
  },
  computed: {
  },
};
</script>

<template>
  <table class="table report-item-table">
    <tr v-for="(item, name) in items">
      <td class="report-item-label-td">
          <label class="font-weight-bold">{{name}}</label>
      </td>
      <td>
        <component
          :is="'report-item-' + item.type"
          v-bind="item"
        />
      </td>
    </tr>
  </table>
</template>
