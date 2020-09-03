<script>
import { GlTable, GlButton } from '@gitlab/ui';

export default {
  components: {
    GlTable,
    GlButton,
  },
  fields: [
    {
      key: 'path',
      label: 'Namespace',
      thClass: '',
      tdClass: '',
    },
    {
      key: 'add_button',
      label: '',
      thClass: '',
      tdClass: '',
    },
  ],
  props: {
    subscriptions: {
      type: Array,
      required: true,
    },
    namespaces: {
      type: Array,
      required: true,
    },
  },
  computed: {
    unsubscribedNamespaces() {
      const subscribedPaths = this.subscriptions.map(subscription => subscription.namespace);
      return this.namespaces.filter(namespace => !subscribedPaths.includes(namespace.path));
    },
  },
};
</script>
<template>
  <gl-table :items="unsubscribedNamespaces" :fields="$options.fields">
    <template #cell(add_button)="{item}">
      <gl-button category="secondary" variant="success" @click="$emit('addSubscription', item)">
        Add subscription
      </gl-button>
    </template>
  </gl-table>
</template>
