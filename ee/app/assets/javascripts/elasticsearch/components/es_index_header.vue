<script>
import EsIndexActions from './es_index_actions.vue';

export default {
  components: {
    EsIndexActions,
  },
  props: {
    index: {
      type: Object,
      required: true,
    },
  },
};
</script>
<template>
  <div class="card-header d-flex align-items-center">
    <div class="header-text-primary flex-fill">
      <strong>{{ index.friendly_name }}</strong>
      <span v-if="index.active_search_source" class="badge badge-info"
        ><strong>{{ s__('Elasticsearch|Search source') }}</strong></span
      >
    </div>
    <es-index-actions :index="index" />
  </div>
</template>
