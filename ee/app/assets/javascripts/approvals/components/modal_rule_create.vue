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
    modalPrimary() {
      return {
        text: this.title,
      };
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
    :modal-primary="modalPrimary"
    modal-module="createModal"
    :modal-id="modalId"
    :title="title"
    @ok.prevent="submit"
  >
    <rule-form ref="form" :init-rule="rule" />
  </gl-modal-vuex>
</template>
