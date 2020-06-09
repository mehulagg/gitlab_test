<script>
import { mapActions, mapState } from 'vuex';
import LicenseComplianceApprovalAction from './approval_action.vue';
import ModalLicenseCompliance from '../modal_license_compliance.vue';

export default {
  components: {
    LicenseComplianceApprovalAction,
    ModalLicenseCompliance,
  },
  computed: {
    ...mapState({
      isLoading: state => state.approvals.isLoading,
      rules: state => state.approvals.rules,
    }),
    licenseCheckRule() {
      return this.rules.find(({ name }) => name === 'License-Check');
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
<template
  ><span
    ><license-compliance-approval-action
      docs-link="http://foo.com"
      :is-license-check-active="Boolean(licenseCheckRule)"
      :is-loading="isLoading"
      @approvalClick="openCreateModal(licenseCheckRule)"/>
    <modal-license-compliance modal-id="yo"
  /></span>
</template>
