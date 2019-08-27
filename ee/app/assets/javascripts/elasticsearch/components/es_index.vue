<script>
import EsIndexHeader from './es_index_header.vue';
import EsIndexBody from './es_index_body.vue';

export default {
  components: {
    EsIndexHeader,
    EsIndexBody,
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
  <div class="card">
    <es-index-header :index="index" />
    <es-index-body :index="index" />
  </div>
</template>
