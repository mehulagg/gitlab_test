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
      required: true,
    }
  },
}
</script>

<template>
  <vulnerability-detail :label="name">
    {{ value }}
  </vulnerability-detail>
</template>
