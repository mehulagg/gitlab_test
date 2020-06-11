<script>
import { mapActions, mapState } from 'vuex';
import ModalLicenseCompliance from '../modal_license_compliance.vue';
import { GlButton, GlIcon, GlLink, GlSkeletonLoading, GlSprintf } from '@gitlab/ui';
import { __ } from '~/locale';

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
      isLoading: ({ approvals }) => approvals.isLoading,
      rules: ({ approvals }) => approvals.rules,
      docsLink: ({ approvals }) => approvals.docsLink,
    }),
    licenseCheckRule() {
      return this.rules?.find(({ name }) => name === 'License-Check');
    },
    licenseCheckStatusText() {
      return this.licenseCheckRule
        ? __('%{docLinkStart}License-Check%{docLinkEnd} is active')
        : __('%{docLinkStart}License-Check%{docLinkEnd} is inactive');
    },
  },
  created() {
    this.fetchRules();
  },
  methods: {
    ...mapActions(['fetchRules']),
    // @TODO - rename the modal action
    ...mapActions({ openCreateModal: 'createModal/open' }),
  },
};
</script>
<template>
  <span class="gl-display-inline-flex gl-align-items-center">
    <gl-button name="openModal" :loading="isLoading" @click="openCreateModal(licenseCheckRule)"
      >{{ __('License Approval') }}
    </gl-button>
    <span class="gl-ml-3">
      <gl-skeleton-loading
        v-if="isLoading"
        :aria-label="__('loading')"
        :lines="1"
        class="gl-display-inline-flex gl-h-auto gl-align-items-center"
      />
      <span v-else data-testid="licenseCheckStatus">
        <gl-icon name="information" :size="12" class="gl-text-blue-600" />
        <gl-sprintf :message="licenseCheckStatusText" class="gl-inline-flex">
          <template #docLink="{ content }">
            <gl-link :href="docsLink" target="_blank">{{ content }}</gl-link>
          </template>
        </gl-sprintf>
      </span>
    </span>
    <modal-license-compliance modal-id="move-me-into-modal" />
  </span>
</template>
