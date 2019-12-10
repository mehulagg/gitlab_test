<script>
import { s__ } from '~/locale';
import ProgressBar from './checkout/progress_bar.vue';
import SubscriptionDetails from './checkout/subscription_details.vue';
import PaymentMethod from './checkout/payment_method.vue';
import BillingAddress from './checkout/billing_address.vue';
import ConfirmOrder from './checkout/confirm_order.vue';

export default {
  components: { ProgressBar, SubscriptionDetails, BillingAddress, PaymentMethod, ConfirmOrder },
  props: {
    store: {
      type: Object,
      required: true,
    },
  },
  i18n: {
    checkout: s__('Checkout|Checkout'),
  },
};
</script>
<template>
  <div id="checkout" class="d-flex flex-column justify-content-between">
    <div class="full-width">
      <progress-bar :step="2" />
      <div class="flash-container"></div>
      <h2>{{ $options.i18n.checkout }}</h2>
      <subscription-details :store="store" />
      <billing-address :store="store" />
      <payment-method :store="store" />
    </div>
    <div class="full-width">
      <confirm-order :store="store" />
    </div>
  </div>
</template>
