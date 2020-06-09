<script>
import { __ } from '~/locale';
import { GlButton, GlIcon, GlLink, GlSkeletonLoading, GlSprintf } from '@gitlab/ui';

export default {
  components: {
    GlButton,
    GlIcon,
    GlLink,
    GlSkeletonLoading,
    GlSprintf,
  },
  props: {
    docsLink: {
      type: String,
      required: true,
    },
    isLicenseCheckActive: {
      type: Boolean,
      required: true,
    },
    isLoading: {
      type: Boolean,
      required: true,
    },
  },
  computed: {
    licenseCheckStatusText() {
      return this.isLicenseCheckActive
        ? // @TODO - use start/end for sprintf
          __('%{docLinkStart}License-Check%{docLinkEnd} is active')
        : __('%{docLinkStart}License-Check%{docLinkEnd} is inactive');
    },
  },
  methods: {
    handleButtonClick() {
      this.$emit('approvalClick');
    },
  },
};
</script>

<template>
  <span class="gl-display-inline-flex gl-align-items-center">
    <gl-button :loading="isLoading" @click="handleButtonClick"
      >{{ __('License Approval') }}
    </gl-button>
    <span class="gl-ml-3">
      <gl-skeleton-loading
        v-if="isLoading"
        :lines="1"
        class="gl-display-inline-flex gl-h-auto gl-align-items-center"
      />
      <span v-else>
        <gl-icon name="information" :size="12" class="gl-text-blue-600" />
        <gl-sprintf :message="licenseCheckStatusText" class="gl-inline-flex">
          <template #docLink="{ content }">
            <gl-link :href="docsLink" target="_blank">{{ content }}</gl-link>
          </template>
        </gl-sprintf>
      </span>
    </span>
  </span>
</template>
