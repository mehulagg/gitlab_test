<script>
import { mapActions, mapState } from 'vuex';
import { GlDeprecatedButton } from '@gitlab/ui';
import ModalLicenseCompliance from '../modal_license_compliance.vue';

export default {
  components: {
    GlDeprecatedButton,
    ModalLicenseCompliance,
  },
  computed: {
    ...mapState({
      isLoading: state => state.approvals.isLoading,
      rules: state => state.approvals.rules,
    }),
    licenseCheckRule() {
      return this.rules?.find(({ name }) => name === 'License-Check');
    },
  },
  created() {
    this.fetchRules();
  },
  methods: {
    ...mapActions(['fetchRules']),
    ...mapActions({ openCreateModal: 'createModal/open' }),
  },
};
</script>
<template>
  <span>
    <span v-if="isLoading">Loading ...</span>
    <span v-else>
      <gl-deprecated-button @click="openCreateModal(licenseCheckRule)">{{
        __('Yoski')
      }}</gl-deprecated-button>
      <modal-license-compliance modal-id="yo" />
    </span>
  </span>
</template>
