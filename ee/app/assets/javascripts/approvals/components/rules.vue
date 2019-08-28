<script>
import { s__ } from '~/locale';
import FallbackRules from './fallback_rules.vue';

const HEADERS = {
  name: s__('ApprovalRule|Name'),
  members: s__('ApprovalRule|Approvers'),
  approvalsRequired: s__('ApprovalRule|No. approvals required'),
};

export default {
  components: {
    FallbackRules,
  },
  props: {
    rules: {
      type: Array,
      required: true,
    },
  },
  HEADERS,
};
</script>

<template>
  <table class="table m-0">
    <thead class="thead-white text-nowrap">
      <slot name="thead" v-bind="$options.HEADERS"></slot>
    </thead>
    <tbody>
      <slot name="fallback-rules">
        <fallback-rules />
      </slot>
      <tr v-for="rule in rules" :key="rule.id">
        <slot :rule="rule" name="tr"></slot>
      </tr>
    </tbody>
  </table>
</template>
