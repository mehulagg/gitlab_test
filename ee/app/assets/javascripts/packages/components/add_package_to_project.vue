<script>
import { GlButton, GlLoadingIcon } from '@gitlab/ui';
import { mapActions, mapState } from 'vuex';
import store from '../stores';

export default {
  name: 'AddPackageToProject',
  components: {
    GlButton,
    GlLoadingIcon,
  },
  props: {
    packageEntity: {
      type: Object,
      required: true,
    },
  },
  store,
  computed: {
    ...mapState(['isLoading']),
  },
  mounted() {
    this.setPackage(this.packageEntity);
  },
  methods: {
    ...mapActions(['setPackage', 'setProjectId', 'addPackageToProject']),
    addPackge() {
      this.setProjectId(9);
      this.addPackageToProject();
    },
  },
};
</script>

<template>
  <div>
    <gl-button variant="success" :disabled="isLoading" @click="addPackge">
      <gl-loading-icon v-if="isLoading" inline />
      <span v-else>{{ s__('PackageRegistry|Add to Project') }}</span>
    </gl-button>
  </div>
</template>
