<script>
import VulnerabilityDetail from '../vulnerability_detail.vue';

export default {
  name: 'ReportItemLabel',
  components: {
    VulnerabilityDetail
  },
  props: {
    name: {
      type: String,
      required: true,
    },
    value: {
      type: String,
      required: false,
    },
    indented: {
      type: Boolean,
      default: true,
      required: false
    },
  },
}
</script>

<template>
  <tr>
    <td class="report-item-label-td">
        <label class="font-weight-bold">{{name}}</label>
    </td>
    <td>{{value}}</td>
  </tr>
</template>
