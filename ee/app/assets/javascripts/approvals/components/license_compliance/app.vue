<script>
import { __ } from '~/locale';
import { mapActions, mapState } from 'vuex';
import { GlButton, GlIcon, GlLink, GlSkeletonLoading, GlSprintf } from '@gitlab/ui';
import ModalLicenseCompliance from '../modal_license_compliance.vue';

export default {
  components: {
    GlButton,
    GlIcon,
    GlLink,
    GlSkeletonLoading,
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
  <span class="gl-display-inline-flex gl-align-items-center">
    <gl-button :loading="isLoading" @click="openCreateModal(licenseCheckRule)"
      >{{ __('License Approval') }}
    </gl-button>
    <span class="gl-ml-3">
      <span v-if="!isLoading">
        <gl-icon name="information" :size="12" class="gl-text-blue-600" />
        <gl-sprintf :message="licenseCheckStatusText" class="gl-inline-flex">
          <template #licenseCheckDocsLink>
            <gl-link href="http://example.com">{{ __('License-Check') }}</gl-link>
          </template>
        </gl-sprintf>
      </span>
      <gl-skeleton-loading
        v-else
        :lines="1"
        class="gl-display-inline-flex gl-h-auto gl-align-items-center"
      />
    </span>
    <modal-license-compliance modal-id="yo" />
  </span>
</template>
