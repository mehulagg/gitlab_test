<script>
import { mapActions } from 'vuex';
import { GlDeprecatedButton } from '@gitlab/ui';
import ModalLicenseCompliance from '../modal_license_compliance.vue';

export default {
  components: {
    GlDeprecatedButton,
    ModalLicenseCompliance,
  },
  methods: {
    ...mapActions({ openCreateModal: 'createModal/open' }),
  },
};
</script>
<template>
  <span>
    <gl-deprecated-button @click="openCreateModal(null)">{{ __('Yoski') }}</gl-deprecated-button>
    <modal-license-compliance modal-id="yo" />
  </span>
</template>
