<template>
  <div :class="{ 'font-monospace': isAnyBranch }">{{ branchName }}</div>
</template>

<script>
import { __ } from '~/locale';

export default {
  props: {
    rule: {
      type: Object,
      required: true,
    },
  },
  computed: {
    branchName() {
      const { protectedBranches } = this.rule;
      const [protectedBranch] = protectedBranches || [];
      return protectedBranch?.name || __('Any branch');
    },
    isAnyBranch() {
      return this.rule.protectedBranches?.length;
    },
  },
};
</script>
