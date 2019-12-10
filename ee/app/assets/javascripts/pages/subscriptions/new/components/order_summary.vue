<script>
import { sprintf, s__ } from '~/locale';
import SummaryDetails from './order_summary/summary_details.vue';

export default {
  components: {
    SummaryDetails,
  },
  props: {
    store: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      state: this.store.state.orderSummary,
      subscriptionDetails: this.store.state.subscriptionDetails,
      collapsed: true,
    };
  },
  computed: {
    totalExVat() {
      return this.pricePerUserPerYear * this.numberOfUsers;
    },
    vat() {
      return this.totalExVat * this.state.taxRate;
    },
    totalAmount() {
      return this.totalExVat + this.vat;
    },
    pricePerUserPerYear() {
      return this.store.getSelectedPlan().pricePerUserPerYear;
    },
    name() {
      return this.subscriptionDetails.setupForCompany
        ? this.organizationName
        : this.subscriptionDetails.fullName;
    },
    organizationName() {
      return this.subscriptionDetails.organizationName
        ? this.subscriptionDetails.organizationName
        : this.$options.i18n.yourOrganization;
    },
    numberOfUsers() {
      return this.subscriptionDetails.numberOfUsers;
    },
    usersPresent() {
      return this.numberOfUsers > 0;
    },
  },
  methods: {
    amount(number) {
      return this.usersPresent
        ? sprintf(this.$options.i18n.amount, {
            amount: (Math.round(number * 100) / 100).toLocaleString(),
          })
        : this.$options.i18n.blank;
    },
    toggleCollapsed() {
      this.collapsed = !this.collapsed;
    },
  },
  i18n: {
    yourOrganization: s__('Checkout|Your organization'),
    title: s__("Checkout|%{name}'s GitLab subscription"),
    amount: s__('Checkout|$%{amount}'),
    blank: s__('Checkout|-'),
  },
};
</script>
<template>
  <div id="order-summary" class="d-flex flex-column prepend-top-32 flex-grow-1">
    <div class="small-media">
      <div class="collapsed" @click="toggleCollapsed">
        <h4 class="d-flex justify-content-between" :class="{ 'prepend-bottom-32': !collapsed }">
          <div class="d-flex">
            <i
              class="fa"
              :class="collapsed ? 'fa-chevron-right' : 'fa-chevron-down'"
              aria-hidden="true"
            ></i>
            <div>{{ sprintf($options.i18n.title, { name }) }}</div>
          </div>
          <div class="prepend-left-default">{{ amount(totalAmount) }}</div>
        </h4>
      </div>
      <div v-show="!collapsed">
        <summary-details
          :store="store"
          :total-ex-vat="totalExVat"
          :vat="vat"
          :total-amount="totalAmount"
          :price-per-user-per-year="pricePerUserPerYear"
          :number-of-users="numberOfUsers"
          :users-present="usersPresent"
          :amount="amount"
        />
      </div>
    </div>
    <div class="large-media">
      <div class="title append-bottom-20">
        <h4>
          {{ sprintf($options.i18n.title, { name }) }}
        </h4>
      </div>
      <summary-details
        :store="store"
        :total-ex-vat="totalExVat"
        :vat="vat"
        :total-amount="totalAmount"
        :price-per-user-per-year="pricePerUserPerYear"
        :number-of-users="numberOfUsers"
        :users-present="usersPresent"
        :amount="amount"
      />
    </div>
  </div>
</template>
