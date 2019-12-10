<script>
import { GlButton } from '@gitlab/ui';
import { sprintf, s__ } from '~/locale';
import Flash from '~/flash';
import { postConfirmOrder } from '../../stores/actions';

export default {
  components: {
    GlButton,
  },
  props: {
    store: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      state: this.store.state.confirmOrder,
    };
  },
  computed: {
    isActive() {
      return this.store.state.currentStep === 'confirmOrder';
    },
  },
  methods: {
    confirmOrder() {
      postConfirmOrder(this.store.confirmOrderParams())
        .then(response => {
          if (response.success) {
            window.location.replace(response.location);
          } else {
            Flash(
              sprintf(this.$options.i18n.failedToConfirmWithErrorMessage, {
                message: response.data.errors,
              }),
            );
          }
        })
        .catch(() => {
          Flash(this.$options.i18n.failedToConfirm);
        });
    },
  },
  i18n: {
    confirm: s__('Checkout|Confirm purchase'),
    failedToConfirm: s__('Checkout|Failed to confirm your order! Please try again.'),
    failedToConfirmWithErrorMessage: s__(
      'Checkout|Failed to confirm your order: "%{message}". Please try again.',
    ),
  },
};
</script>
<template>
  <div v-if="isActive" class="prepend-bottom-32">
    <gl-button variant="success" @click="confirmOrder">
      {{ $options.i18n.confirm }}
    </gl-button>
  </div>
</template>
