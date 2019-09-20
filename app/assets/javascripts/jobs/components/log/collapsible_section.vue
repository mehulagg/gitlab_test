<script>
import LogLine from './line.vue';
import LogLineHeader from './line_header.vue';

export default {
  name: 'collpasible-log-section',
  components: {
    LogLine,
    LogLineHeader,
  },
  props: {
    section: {
      type: Object,
      required: true,
    },
    traceEndpoint: {
      type: String,
      required: true,
    },
  },
  methods: {
    handleOnClickCollapsibleLine(section) {
      this.$emit('handleOnClickCollapsibleLine', section);
    },
  },
};
</script>
<template>
  <div>
    <log-line-header
      :line="section.line"
      :duration="section.line.section_duration"
      :path="traceEndpoint"
      :is-closed="section.isClosed"
      @toggleLine="handleOnClickCollapsibleLine(section)"
    />
    <template v-if="!section.isClosed">
      <log-line v-for="line in section.lines" :key="line.offset" :line="line" :path="traceEndpoint" />
    </template>
  </div>
</template>