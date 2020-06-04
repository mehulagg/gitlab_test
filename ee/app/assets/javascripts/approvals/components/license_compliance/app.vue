<script>
import { __ } from '~/locale';
import { mapActions, mapState } from 'vuex';
import { GlDeprecatedButton as GlButton, GlIcon, GlLink, GlSprintf } from '@gitlab/ui';
import ModalLicenseCompliance from '../modal_license_compliance.vue';

export default {
  components: {
    GlButton,
    GlIcon,
    GlLink,
    GlSprintf,
    ModalLicenseCompliance,
  },
  computed: {
    ...mapState({
      isLoading: state => state.approvals.isLoading,
      rules: state => state.approvals.rules,
    }),
    licenseCheckRule() {
      // @TODO - move rule name to constant
      return this.rules?.find(({ name }) => name === 'License-Check');
    },
    licenseCheckStatusText() {
      return this.licenseCheckRule && this.licenseCheckRule.approvalsRequired > 0
        ? __('%{licenseCheckDocsLink} is active')
        : __('%{licenseCheckDocsLink} is inactive');
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
    <span v-else class="gl-display-inline-flex gl-align-items-center">
      <gl-button @click="openCreateModal(licenseCheckRule)">{{ __('License Approval') }}</gl-button>
      <span class="gl-ml-3">
        <gl-icon name="information" :size="12" class="gl-text-blue-600" />
        <gl-sprintf :message="licenseCheckStatusText">
          <template #licenseCheckDocsLink>
            <gl-link href="http://example.com">{{ __('License-Check') }}</gl-link>
          </template>
        </gl-sprintf>
      </span>
      <modal-license-compliance modal-id="yo" />
    </span>
  </span>
</template>
