<script>
import { mapState } from 'vuex';
import { GlButton, GlIcon, GlLink, GlSprintf } from '@gitlab/ui';
import { __ } from '~/locale';
import GlModalVuex from '~/vue_shared/components/gl_modal_vuex.vue';
import RuleForm from './rule_form.vue';

export default {
  components: {
    GlButton,
    GlIcon,
    GlLink,
    GlSprintf,
    GlModalVuex,
    RuleForm,
  },
  props: {
    modalId: {
      type: String,
      required: true,
    },
  },
  computed: {
    ...mapState('createModal', {
      rule: 'data',
    }),
    title() {
      return this.rule ? __('Update approval rule') : __('Add approval rule');
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
    modal-module="createModal"
    :modal-id="modalId"
    :title="title"
    ok-variant="success"
    :cancel-title="__('Cancel')"
    size="sm"
    @ok="submit"
  >
    <rule-form ref="form" :init-rule="rule" locked-name="License-Check" />
    <template #modal-footer="{ ok, cancel }">
      <div class="d-flex w-100">
        <p>
          <gl-icon name="question" :size="12" class="text-primary-600" />
          <gl-sprintf :message="__('Learn more about %{licenseCheckHelpLink}')">
            <template #licenseCheckHelpLink>
              <gl-link href="http://example.com" target="_blank">{{ __('License-Check') }}</gl-link>
            </template>
          </gl-sprintf>
        </p>
        <div class="ml-auto">
          <gl-button @click="cancel">{{ __('Cancel') }}</gl-button>
          <gl-button variant="success" @click="ok">{{ title }}</gl-button>
        </div>
      </div>
    </template>
  </gl-modal-vuex>
</template>
