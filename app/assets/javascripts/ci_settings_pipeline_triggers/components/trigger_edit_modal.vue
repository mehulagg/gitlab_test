<script>
import { GlModal, GlForm, GlFormGroup, GlFormText, GlFormInput } from '@gitlab/ui';
import { s__ } from '~/locale';

export default {
  components: {
    GlModal,
    GlForm,
    GlFormGroup,
    GlFormText,
    GlFormInput,
  },
  props: {
    modalId: {
      type: String,
      required: true,
    },
    trigger: {
      type: Object,
      required: false,
      default: null,
    },
  },
  data() {
    return {
      triggerModel: {
        description: '',
        ...this.trigger,
      },
    };
  },
  methods: {
    onPrimary() {
      // TODO Implement the 'submit' call
    },
  },
  actionPrimary: {
    text: s__('Pipelines|Save trigger'),
    attributes: {
      variant: 'success',
    },
  },
  actionCancel: {
    text: s__('Pipelines|Cancel'),
  },
};
</script>

<template>
  <gl-form ref="form">
    <gl-modal
      :modal-id="modalId"
      :title="s__('Pipelines|Update Trigger')"
      :action-primary="$options.actionPrimary"
      :action-cancel="$options.actionCancel"
      @primary.prevent="onPrimary"
    >
      <gl-form-group
        v-if="triggerModel.token"
        id="trigger_token"
        :label="s__('Pipelines|Token')"
        label-for="trigger_description"
      >
        <gl-form-text>{{ trigger.token }}</gl-form-text>
      </gl-form-group>
      <gl-form-group
        id="trigger_description"
        :label="s__('Pipelines|Description')"
        label-for="trigger_description"
      >
        <gl-form-input id="trigger_description" v-model="triggerModel.description" />
      </gl-form-group>
    </gl-modal>
  </gl-form>
</template>
