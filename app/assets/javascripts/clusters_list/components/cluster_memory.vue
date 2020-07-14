<script>
import { GlSprintf } from '@gitlab/ui';
import { calculatePercentage, sumNodeMemoryAndUsage } from '../utils';
import { mapActions } from 'vuex';

export default {
  components: {
    GlSprintf,
  },
  props: {
    nodes: {
      required: true,
      type: Array,
    },
  },
  computed: {
    totalMemoryAndUsage() {
      try {
        // For EKS node.usage will not be present unless the user manually
        // install the metrics server
        if (this.nodes[0].usage) {
          const { allocated, used } = this.nodes.reduce(sumNodeMemoryAndUsage, {
            allocated: 0,
            used: 0,
          });

          return {
            totalMemory: allocated.toFixed(2),
            freeSpacePercentage: calculatePercentage(allocated, used),
          };
        }
      } catch (error) {
        this.reportSentryError({ error, tag: 'totalMemoryAndUsageError' });
      }

      return { totalMemory: null, freeSpacePercentage: null };
    },
  },
  methods: {
    ...mapActions(['reportSentryError']),
  },
};
</script>

<template>
  <gl-sprintf
    v-if="totalMemoryAndUsage.totalMemory"
    :message="__('%{totalMemory} (%{freeSpacePercentage}%{percentSymbol} free)')"
  >
    <template #totalMemory>{{ totalMemoryAndUsage.totalMemory }}</template>

    <template #freeSpacePercentage>{{ totalMemoryAndUsage.freeSpacePercentage }}</template>

    <template #percentSymbol
      >%</template
    >
  </gl-sprintf>
</template>
