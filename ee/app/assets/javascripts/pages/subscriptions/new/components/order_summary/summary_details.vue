<script>
import dateFormat from 'dateformat';
import { s__ } from '~/locale';

export default {
  props: {
    store: {
      type: Object,
      required: true,
    },
    totalExVat: {
      type: Number,
      required: true,
    },
    vat: {
      type: Number,
      required: true,
    },
    totalAmount: {
      type: Number,
      required: true,
    },
    pricePerUserPerYear: {
      type: Number,
      required: true,
    },
    numberOfUsers: {
      type: Number,
      required: true,
    },
    usersPresent: {
      type: Boolean,
      required: true,
    },
    amount: {
      type: Function,
      required: true,
    },
  },
  data() {
    return {
      state: this.store.state.orderSummary,
    };
  },
  computed: {
    selectedPlanText() {
      return this.store.getSelectedPlan().text;
    },
  },
  methods: {
    formattedDate(date) {
      return dateFormat(date, 'mmm d, yyyy');
    },
  },
  i18n: {
    selectedPlanText: s__('Checkout|%{selectedPlanText} plan'),
    numberOfUsers: s__('Checkout|(x%{numberOfUsers})'),
    pricePerUserPerYear: s__('Checkout|$%{pricePerUserPerYear} per user per year'),
    dates: s__('Checkout|%{startDate} - %{endDate}'),
    subtotal: s__('Checkout|Subtotal'),
    tax: s__('Checkout|Tax'),
    total: s__('Checkout|Total'),
  },
};
</script>
<template>
  <div>
    <div class="line header d-flex justify-content-between bold">
      <div class="selected-plan">
        {{ sprintf($options.i18n.selectedPlanText, { selectedPlanText }) }}
        <span v-if="usersPresent" class="number-of-users">{{
          sprintf($options.i18n.numberOfUsers, { numberOfUsers })
        }}</span>
      </div>
      <div class="amount">{{ amount(totalExVat) }}</div>
    </div>
    <div class="line text-secondary per-user">
      {{
        sprintf($options.i18n.pricePerUserPerYear, {
          pricePerUserPerYear: pricePerUserPerYear.toLocaleString(),
        })
      }}
    </div>
    <div class="line text-secondary dates">
      {{
        sprintf($options.i18n.dates, {
          startDate: formattedDate(state.startDate),
          endDate: formattedDate(state.endDate),
        })
      }}
    </div>
    <div v-if="state.taxRate">
      <div class="divider"></div>
      <div class="line d-flex justify-content-between text-secondary">
        <div>{{ $options.i18n.subtotal }}</div>
        <div class="total-ex-vat">{{ amount(totalExVat) }}</div>
      </div>
      <div class="line d-flex justify-content-between text-secondary">
        <div>{{ $options.i18n.tax }}</div>
        <div class="vat">{{ amount(vat) }}</div>
      </div>
    </div>
    <div class="divider"></div>
    <div class="line d-flex justify-content-between bold gl-font-size-large">
      <div>{{ $options.i18n.total }}</div>
      <div class="total-amount">{{ amount(totalAmount) }}</div>
    </div>
  </div>
</template>
