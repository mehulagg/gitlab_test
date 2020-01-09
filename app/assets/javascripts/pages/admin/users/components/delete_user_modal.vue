<script>
import _ from 'underscore';
import { GlModal, GlFormInput } from '@gitlab/ui';
import { s__, sprintf } from '~/locale';

export default {
  components: {
    GlModal,
    GlFormInput,
  },
  props: {
    title: {
      type: String,
      required: true,
    },
    content: {
      type: String,
      required: true,
    },
    action: {
      type: String,
      required: true,
    },
    secondaryAction: {
      type: String,
      required: true,
    },
    deleteUserUrl: {
      type: String,
      required: true,
    },
    blockUserUrl: {
      type: String,
      required: true,
    },
    username: {
      type: String,
      required: true,
    },
    csrfToken: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      enteredUsername: '',
    };
  },
  computed: {
    modalTitle() {
      return sprintf(this.title, { username: this.username });
    },
    text() {
      return sprintf(
        this.content,
        {
          username: `<strong>${_.escape(this.username)}</strong>`,
          strong_start: '<strong>',
          strong_end: '</strong>',
        },
        false,
      );
    },
    confirmationTextLabel() {
      return sprintf(
        s__('AdminUsers|To confirm, type %{username}'),
        {
          username: `<code>${_.escape(this.username)}</code>`,
        },
        false,
      );
    },

    secondaryButtonLabel() {
      return s__('AdminUsers|Block user');
    },
    canSubmit() {
      return this.enteredUsername === this.username;
    },
    modalPrimary() {
      return {
        text: this.action,
        attributes: [{ variant: 'danger' }, { disabled: !this.canSubmit }],
      };
    },
    modalSecondary() {
      return {
        text: this.secondaryAction,
        attributes: [{ variant: 'warning' }, { disabled: !this.canSubmit }],
      };
    },
  },
  methods: {
    show() {
      this.$refs.modal.show();
    },
    onCancel() {
      this.enteredUsername = '';
      this.$refs.modal.hide();
    },
    onSecondaryAction() {
      const { form } = this.$refs;

      form.action = this.blockUserUrl;
      this.$refs.method.value = 'put';

      form.submit();
    },
    onSubmit() {
      this.$refs.form.submit();
      this.enteredUsername = '';
    },
  },
};
</script>

<template>
  <gl-modal
    ref="modal"
    modal-id="delete-user-modal"
    :title="modalTitle"
    kind="danger"
    :modal-action-primary="modalPrimary"
    :modal-action-secondary="modalSecondary"
    @ok="onSubmit"
    @cancel="onCancel"
    @close="onSecondaryAction"
  >
    <template>
      <p v-html="text"></p>
      <p v-html="confirmationTextLabel"></p>
      <form ref="form" :action="deleteUserUrl" method="post" @submit.prevent>
        <input ref="method" type="hidden" name="_method" value="delete" />
        <input :value="csrfToken" type="hidden" name="authenticity_token" />
        <gl-form-input
          v-model="enteredUsername"
          autofocus
          type="text"
          name="username"
          autocomplete="off"
        />
      </form>
    </template>
  </gl-modal>
</template>
