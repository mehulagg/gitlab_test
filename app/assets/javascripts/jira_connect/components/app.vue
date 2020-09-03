<script>
import SubscriptionTable from './subscription_table.vue';
import NamespaceTable from './namespace_table.vue';
import { addSubscription, removeSubscription } from '~/jira_connect/api';

const reqComplete = () => {
  AP.navigator.reload();
};

export default {
  components: {
    SubscriptionTable,
    NamespaceTable,
  },
  props: {
    subscriptionPath: {
      type: String,
      required: true,
    },
    subscriptions: {
      type: Array,
      required: true,
    },
    namespaces: {
      type: Array,
      required: true,
    },
  },
  data() {
    return {
      error: null,
    };
  },
  methods: {
    reqFail(res) {
      this.error = res.data.error;
    },
    addSubscription(namespace) {
      addSubscription(this.subscriptionPath, namespace)
        .then(reqComplete)
        .catch(this.reqFail);
    },
    removeSubscription(subscription) {
      removeSubscription(subscription)
        .then(reqComplete)
        .catch(this.reqFail);
    },
  },
};
</script>
<template>
  <div>
    <pre v-if="error">{{ error }}</pre>
    <subscription-table :subscriptions="subscriptions" @removeSubscription="removeSubscription" />
    <namespace-table
      :subscriptions="subscriptions"
      :namespaces="namespaces"
      @addSubscription="addSubscription"
    />
  </div>
</template>
