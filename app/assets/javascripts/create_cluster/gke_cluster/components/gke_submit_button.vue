<script>
import { mapGetters } from 'vuex';
import { GlButton } from '@gitlab/ui';

export default {
  components: {
    GlButton,
  },
  computed: {
    ...mapGetters(['hasValidData']),
  },
};
</script>
<template>
  <gl-button
    type="submit"
    variant="success"
    :disabled="!hasValidData"
    class="js-gke-cluster-creation-submit"
  >
    {{ s__('ClusterIntegration|Create Kubernetes cluster') }}
  </gl-button>
</template>
