<script>
import { mapActions } from 'vuex';
import SubscriptionTable from './subscription_table.vue';

export default {
  name: 'SubscriptionApp',
  components: {
    SubscriptionTable,
  },
  props: {
    namespaceId: {
      type: String,
      required: true,
      default: null,
    },
    groupLevelName: {
      type: String,
      required: true,
      default: null,
    },
  },
  created() {
    this.setNamespaceId(this.namespaceId);
    this.setGroupLevelName(this.groupLevelName);
  },
  methods: {
    ...mapActions('subscription', ['setNamespaceId', 'setGroupLevelName']),
  },
};
</script>

<template>
  <subscription-table />
</template>
