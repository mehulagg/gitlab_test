<script>
import { GlSearchBoxByClick, GlTable } from '@gitlab/ui';
import { __ } from '~/locale';

export default {
  components: {
    GlSearchBoxByClick,
    GlTable,
  },
  data() {
    return {
      searchTerm: null,
      logs: {
        fields: [
          {
            key: 'timestamp',
            label: __('Timestamp'),
          },
          {
            key: 'log_message',
            label: __('Log Message'),
          },
        ],
        items: [
          {
            timestamp: '2019-01-01 09:20PM',
            log_message: 'Log message...',
          },
          {
            timestamp: '2019-01-01 09:20PM',
            log_message: 'Log message...',
          },
        ],
      },
    };
  },
  methods: {
    submitted() {
      console.log('submitted', this.searchTerm);
    },
  },
};
</script>

<template>
  <div class="build-page-pod-logs mt-3">
    <div class="top-bar js-top-bar d-flex">
      <gl-search-box-by-click
        v-model="searchTerm"
        @submit="submitted()"
        class="w-100"
        :autofocus="true"
        :placeholder="__('Search for keyword from log results')"
      />
    </div>
    {{ searchTerm }}
    <gl-table :items="logs.items" :fields="logs.fields">
      <template slot="log_message" slot-scope="items">
        <pre>{{ items.item.log_message }}</pre>
      </template>
    </gl-table>
  </div>
</template>
