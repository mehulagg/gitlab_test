<script>
import { GlTable, GlButton } from '@gitlab/ui';

export default {
  components: {
    GlTable,
    GlButton,
  },
  fields: [
    {
      key: 'namespace',
      label: 'Namespace',
      thClass: '',
      tdClass: '',
    },
    {
      key: 'created_at',
      label: 'Added',
      thClass: '',
      tdClass: '',
    },
    {
      key: 'remove_button',
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
  },
};
</script>
<template>
  <gl-table :items="subscriptions" :fields="$options.fields">
    <template #cell(remove_button)="{item}">
      <gl-button category="secondary" variant="danger" @click="$emit('removeSubscription', item)">
        Remove
      </gl-button>
    </template>
  </gl-table>
</template>
