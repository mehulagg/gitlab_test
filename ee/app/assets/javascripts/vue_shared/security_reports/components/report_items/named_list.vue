<script>
import ReportItemLabel from './label.vue';
import ReportItemList from './list.vue';
import ReportItemHexInt from './hex_int.vue';
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
    ReportItemHexInt
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
  <div class="report-item-list">
    <div v-for="(item, name) in items">
      <report-item-label
        v-if="item.type == 'label'"
        :name="name"
        :value="item.value"
       />

      <vulnerability-detail :label="name">
        <component
          :is="'report-item-' + item.type"
          v-if="item.type != 'label'"
          v-bind="item"
        />
      </vulnerability-detail>
    </div>
  </div>
</template>
