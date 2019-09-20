<script>
import LineNumber from './line_number.vue';
import DurationBadge from './duration_badge.vue';

export default {
  components: {
    LineNumber,
    DurationBadge,
  },
  props: {
    line: {
      type: Object,
      required: true,
    },
    path: {
      type: String,
      required: true,
    },
  },
  computed: {
    hasContent() {
      return this.line.content && this.line.content.length;
    },
  },
};
</script>

<template>
  <div class="line">
    <line-number :line-number="line.lineNumber" :path="path" />
    <span v-for="(content, i) in line.content" :key="i" :class="content.style">
      {{
      content.text
      }}
    </span>
    <duration-badge
      v-if="line.section_duration"
      :duration="line.section_duration"
      :class="{'float-right' : !hasContent}"
    />
  </div>
</template>
