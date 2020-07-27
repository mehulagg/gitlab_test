<script>
import { GlModal, GlSprintf, GlButton } from '@gitlab/ui';
import { s__, __ } from '~/locale';

export default {
  components: {
    GlModal,
    GlSprintf,
    GlButton,
  },
  props: {
    limit: {
      type: String,
      required: true,
    },
    modalId: {
      type: String,
      required: true,
    },
    increaseStorageTemporarily: {
      type: Function,
      required: true,
    },
  },
  data() {
    return {
      isLoading: false,
    };
  },
  methods: {
    async submit() {
      this.isLoading = true;
      await this.increaseStorageTemporarily();
      this.$refs.modal.hide();
    },
    closeModal() {
      this.$refs.modal.hide();
    },
  },
  modalBody: s__(
    "TemporaryStorage|GitLab allows you a %{strongStart}free, one-time storage increase%{strongEnd}. For 30 days your storage will be unlimited. This gives you time to reduce your storage usage. After 30 days, your original storage limit of %{limit} applies. If you are at maximum storage capacity, your account will be read-only. To continue using GitLab you'll have to purchase additional storage or decrease storage usage.",
  ),
  modalTitle: s__('TemporaryStorage|Temporarily increase storage now?'),
  okTitle: s__('TemporaryStorage|Increase storage temporarily'),
  cancelTitle: __('Cancel'),
};
</script>
<template>
  <gl-modal
    size="sm"
    ok-variant="success"
    :title="$options.modalTitle"
    :modal-id="modalId"
    ref="modal"
    @ok="submit"
  >
    <gl-sprintf :message="$options.modalBody">
      <template #strong="{ content }">
        <strong>{{ content }}</strong>
      </template>
      <template #limit>{{ limit }}</template>
    </gl-sprintf>
    <template #modal-footer>
      <gl-button @click="closeModal">{{ $options.cancelTitle }}</gl-button>
      <gl-button variant="success" category="primary" :loading="isLoading" @click="submit">
        {{ $options.okTitle }}
      </gl-button>
    </template>
  </gl-modal>
</template>
