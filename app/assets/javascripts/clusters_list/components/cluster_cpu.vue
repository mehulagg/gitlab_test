<script>
import { GlSprintf } from '@gitlab/ui';
import { calculatePercentage, sumNodeCpuAndUsage } from '../utils';
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
    totalCpuAndUsage() {
      try {
        // For EKS node.usage will not be present unless the user manually
        // install the metrics server
        if (this.nodes[0].usage) {
          const { allocated, used } = this.nodes.reduce(sumNodeCpuAndUsage, {
            allocated: 0,
            used: 0,
          });

          return {
            totalCpu: allocated.toFixed(2),
            freeSpacePercentage: calculatePercentage(allocated, used),
          };
        }
      } catch (error) {
        this.reportSentryError({ error, tag: 'totalCpuAndUsageError' });
      }

      return { totalCpu: null, freeSpacePercentage: null };
    },
  },
  methods: {
    ...mapActions(['reportSentryError']),
  },
};
</script>

<template>
  <gl-sprintf
    v-if="totalCpuAndUsage.totalCpu"
    :message="__('%{totalCpu} (%{freeSpacePercentage}%{percentSymbol} free)')"
  >
    <template #totalCpu>{{ totalCpuAndUsage.totalCpu }}</template>

    <template #freeSpacePercentage>{{ totalCpuAndUsage.freeSpacePercentage }}</template>

    <template #percentSymbol
      >%</template
    >
  </gl-sprintf>
</template>
