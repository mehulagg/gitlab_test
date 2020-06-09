<script>
import { mapGetters } from 'vuex';

export default {
  computed: {
    ...mapGetters(['hasValidData']),
  },
};
</script>
<template>
  <button
    type="submit"
    :disabled="!hasValidData"
    class="js-gke-cluster-creation-submit btn gl-button-deprecated btn-success"
  >
    {{ s__('ClusterIntegration|Create Kubernetes cluster') }}
  </button>
</template>
