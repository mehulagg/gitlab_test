<script>
import { mapState } from 'vuex';
import { GlButton, GlIcon, GlLink, GlSprintf } from '@gitlab/ui';
import { __ } from '~/locale';
import GlModalVuex from '~/vue_shared/components/gl_modal_vuex.vue';
import RuleForm from '../rule_form.vue';

export default {
  components: {
    GlButton,
    GlIcon,
    GlLink,
    GlSprintf,
    GlModalVuex,
    RuleForm,
  },
  computed: {
    ...mapState('approvalModal', {
      licenseApprovalRule: 'data',
    }),
    ...mapState({
      documentationPath: ({ settings }) => settings.approvalsDocumentationPath,
    }),
    title() {
      return this.licenseApprovalRule ? __('Update approvers') : __('Add approvers');
    },
  },
  methods: {
    submit() {
      this.$refs.form.submit();
    },
  },
};
</script>

<template>
  <gl-modal-vuex
    modal-module="approvalModal"
    modal-id="licenseComplianceApproval"
    :title="title"
    size="sm"
    @ok="submit"
  >
    <rule-form ref="form" :init-rule="licenseApprovalRule" locked-name="License-Check" />
    <template #modal-footer="{ ok, cancel }">
      <div class="gl-display-flex gl-w-full">
        <p>
          <gl-icon name="question" :size="12" class="gl-text-blue-600" />
          <gl-sprintf :message="__('Learn more about %{licenseCheckHelpLink}')">
            <template #licenseCheckHelpLink>
              <gl-link :href="documentationPath" target="_blank">{{
                __('License Approvals')
              }}</gl-link>
            </template>
          </gl-sprintf>
        </p>
        <div class="gl-ml-auto">
          <gl-button name="cancel" @click="cancel">{{ __('Cancel') }}</gl-button>
          <gl-button name="ok" variant="success" @click="ok">{{ title }}</gl-button>
        </div>
      </div>
    </template>
  </gl-modal-vuex>
</template>
