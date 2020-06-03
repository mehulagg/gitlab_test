<script>
import { mapState } from 'vuex';
import { __ } from '~/locale';
import GlModalVuex from '~/vue_shared/components/gl_modal_vuex.vue';
import RuleForm from './rule_form.vue';

export default {
  components: {
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
        <p>Yo this is the message of the day</p>
        <div class="ml-auto">
          <button @click="cancel">{{ __('Cancel') }}</button>
          <button @click="ok">{{ title }}</button>
        </div>
      </div>
    </template>
  </gl-modal-vuex>
</template>
