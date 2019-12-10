import { parseBoolean } from '~/lib/utils/common_utils';
import { STEPS, TAX_RATE } from './constants';

export default class SubscriptionStore {
  constructor() {
    this.state = {};
    [this.state.currentStep] = STEPS;
    this.state.subscriptionDetails = {
      availablePlans: [],
      selectedPlan: undefined,
      setupForCompany: undefined,
      fullName: undefined,
      organizationName: undefined,
      numberOfUsers: 0,
    };
    this.state.billingAddress = {
      country: null,
      streetAddressLine1: undefined,
      streetAddressLine2: undefined,
      city: undefined,
      state: null,
      zipCode: undefined,
    };
    this.state.paymentMethod = {
      paymentMethodId: undefined,
    };
    this.state.orderSummary = {
      taxRate: TAX_RATE,
      startDate: new Date(),
      get endDate() {
        return new Date(this.startDate).setFullYear(this.startDate.getFullYear() + 1);
      },
    };
  }

  confirmOrderParams() {
    return {
      setup_for_company: this.state.subscriptionDetails.setupForCompany,
      customer: {
        country: this.state.billingAddress.country,
        address_1: this.state.billingAddress.streetAddressLine1,
        address_2: this.state.billingAddress.streetAddressLine2,
        city: this.state.billingAddress.city,
        state: this.state.billingAddress.state,
        zip_code: this.state.billingAddress.zipCode,
        company: this.state.subscriptionDetails.organizationName,
      },
      subscription: {
        plan_id: this.state.subscriptionDetails.selectedPlan,
        payment_method_id: this.state.paymentMethod.paymentMethodId,
        quantity: this.state.subscriptionDetails.numberOfUsers,
      },
    };
  }

  setInitialData({ setupForCompany, fullName, planData, planId }) {
    this.state.subscriptionDetails.setupForCompany = parseBoolean(setupForCompany);
    this.state.subscriptionDetails.fullName = fullName;
    this.setPlans(planData);
    this.setSelectedPlan(planId);
    this.setNumberOfUsers();
  }

  setPlans(planData) {
    const availablePlans = JSON.parse(planData).map(plan => ({
      value: plan.id,
      text: plan.code.charAt(0).toUpperCase() + plan.code.slice(1),
      pricePerUserPerYear: plan.price_per_year,
    }));
    this.state.subscriptionDetails.availablePlans = availablePlans;
  }

  setSelectedPlan(planId) {
    const { availablePlans } = this.state.subscriptionDetails;
    if (planId && availablePlans.find(plan => plan.value === planId)) {
      this.state.subscriptionDetails.selectedPlan = planId;
      return;
    }
    this.state.subscriptionDetails.selectedPlan = availablePlans[0] ? availablePlans[0].value : '';
  }

  setNumberOfUsers() {
    if (!this.state.subscriptionDetails.setupForCompany) {
      this.state.subscriptionDetails.numberOfUsers = 1;
    }
  }

  getSelectedPlan() {
    return this.state.subscriptionDetails.availablePlans.find(
      plan => plan.value === this.state.subscriptionDetails.selectedPlan,
    );
  }

  activateStep(name) {
    if (SubscriptionStore.stepIndex(name) > -1) {
      this.state.currentStep = name;
    }
  }

  nextStep() {
    if (this.activeStepIndex() < STEPS.length - 1) {
      this.state.currentStep = STEPS[this.activeStepIndex() + 1];
    }
  }

  activeStepIndex() {
    return SubscriptionStore.stepIndex(this.state.currentStep);
  }

  static stepIndex(step) {
    return STEPS.findIndex(el => el === step);
  }
}
