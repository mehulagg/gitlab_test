import Vue from 'vue';
import Checkout from './components/checkout.vue';
import OrderSummary from './components/order_summary.vue';
import SubscriptionStore from './stores/subscription_store';

document.addEventListener('DOMContentLoaded', () => {
  const store = new SubscriptionStore();
  const checkoutEl = document.getElementById('checkout');
  store.setInitialData(checkoutEl.dataset);

  // eslint-disable-next-line no-new
  new Vue({
    el: checkoutEl,
    components: { Checkout },
    render(createElement) {
      return createElement('checkout', {
        props: { store },
      });
    },
  });

  // eslint-disable-next-line no-new
  new Vue({
    el: '#summary',
    components: { OrderSummary },
    render(createElement) {
      return createElement('order-summary', {
        props: { store },
      });
    },
  });
});
