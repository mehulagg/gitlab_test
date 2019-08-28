<script>
import { mapState } from 'vuex';
import Icon from '~/vue_shared/components/icon.vue';
import UserAvatarList from '~/vue_shared/components/user_avatar/user_avatar_list.vue';
import RuleControls from './rule_controls.vue';

export default {
  components: {
    Icon,
    UserAvatarList,
    RuleControls,
  },
  props: {
    hasControls: {
      type: Boolean,
      required: false,
      default: true,
    },
  },
  computed: {
    ...mapState({
      approvalsRequired: state => state.approvals.fallbackApprovalsRequired,
      minApprovalsRequired: state => state.approvals.minFallbackApprovalsRequired || 0,
    }),
    rule() {
      return {
        isFallback: true,
        approvalsRequired: this.approvalsRequired,
        minApprovalsRequired: this.minApprovalsRequired,
      };
    },
  },
};
</script>

<template>
  <tr>
    <td class="pl-0" colspan="2">
      {{ s__('ApprovalRule|All members with Developer role or higher and code owners (if any)') }}
    </td>
    <td class="text-nowrap">
      <slot
        name="approvals-required"
        :approvals-required="rule.approvalsRequired"
        :min-approvals-required="rule.minApprovalsRequired"
      >
        <icon name="approval" class="align-top text-tertiary" />
        <span>{{ rule.approvalsRequired }}</span>
      </slot>
    </td>
    <td class="text-nowrap px-2 w-0">
      <rule-controls v-if="hasControls" :rule="rule" />
    </td>
  </tr>
</template>
