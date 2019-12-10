<script>
import _ from 'underscore';
import { GlSprintf } from '@gitlab/ui';
import { s__ } from '~/locale';
import Flash from '~/flash';
import Step from './components/step.vue';
import Zuora from './components/zuora.vue';
import { loadPaymentMethodDetails } from '../../stores/actions';

export default {
  components: {
    GlSprintf,
    Step,
    Zuora,
  },
  props: {
    store: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      state: this.store.state.paymentMethod,
      cardType: undefined,
      lastFourDigits: undefined,
      expirationMonth: undefined,
      expirationYear: undefined,
    };
  },
  computed: {
    isValid() {
      return !_.isEmpty(this.state.paymentMethodId);
    },
  },
  methods: {
    loadDetails(paymentMethodId, detailsLoadedCallback) {
      this.state.paymentMethodId = paymentMethodId;
      loadPaymentMethodDetails(paymentMethodId)
        .then(data => {
          this.setCreditCardDetails(data);
          detailsLoadedCallback();
          this.store.nextStep();
        })
        .catch(() => {
          Flash(this.$options.i18n.failedToRegisterCreditCard);
        });
    },
    setCreditCardDetails(data) {
      this.cardType = data.credit_card_type;
      this.lastFourDigits = data.credit_card_mask_number.slice(-4);
      this.expirationMonth = data.credit_card_expiration_month;
      this.expirationYear = data.credit_card_expiration_year % 100;
    },
  },
  i18n: {
    stepTitle: s__('Checkout|Payment method'),
    creditCardDetails: s__('Checkout|%{cardType} ending in %{lastFourDigits}'),
    expirationDate: s__('Checkout|Exp %{expirationMonth}/%{expirationYear}'),
    failedToRegisterCreditCard: s__('Checkout|Failed to register credit card. Please try again.'),
  },
};
</script>
<template>
  <step step="paymentMethod" :store="store" :title="$options.i18n.stepTitle" :is-valid="isValid">
    <template v-slot:body="props">
      <zuora :active="props.active" :success="loadDetails" />
    </template>
    <template #summary>
      <div>
        <gl-sprintf :message="$options.i18n.creditCardDetails">
          <template #cardType>
            {{ cardType }}
          </template>
          <template #lastFourDigits>
            <strong>{{ lastFourDigits }}</strong>
          </template>
        </gl-sprintf>
      </div>
      <div>
        {{ sprintf($options.i18n.expirationDate, { expirationMonth, expirationYear }) }}
      </div>
    </template>
  </step>
</template>
