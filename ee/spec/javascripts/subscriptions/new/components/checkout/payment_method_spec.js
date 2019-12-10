import Vue from 'vue';
import component from 'ee/pages/subscriptions/new/components/checkout/payment_method.vue';
import Store from 'ee/pages/subscriptions/new/stores/subscription_store';
import mountComponent from 'spec/helpers/vue_mount_component_helper';

describe('Payment Method', () => {
  let vm;
  let props;
  const store = new Store();
  const Component = Vue.extend(component);

  beforeEach(() => {
    props = { store };
    vm = mountComponent(Component, props);
  });

  afterEach(() => {
    vm.$destroy();
  });

  describe('Validations', () => {
    it('should be valid when paymentMethodId is present', () => {
      store.state.paymentMethod.paymentMethodId = 'x';

      expect(vm.isValid).toBeTruthy();
    });

    it('should be invalid when paymentMethodId is undefined', () => {
      store.state.paymentMethod.paymentMethodId = undefined;

      expect(vm.isValid).toBeFalsy();
    });
  });

  describe('setCreditCardDetails', () => {
    beforeEach(() => {
      const data = {
        credit_card_expiration_month: 2,
        credit_card_expiration_year: 2020,
        credit_card_mask_number: '************4242',
        credit_card_type: 'Visa',
      };
      vm.setCreditCardDetails(data);
    });

    it('should set the cardType', () => {
      expect(vm.cardType).toEqual('Visa');
    });

    it('should set the lastFourDigits to the last 4 characters of the credit_card_mask_number', () => {
      expect(vm.lastFourDigits).toEqual('4242');
    });

    it('should set the expirationMonth', () => {
      expect(vm.expirationMonth).toEqual(2);
    });

    it('should set the expirationYear to the last two digits of the returned credit_card_expiration_year', () => {
      expect(vm.expirationYear).toEqual(20);
    });
  });

  describe('Showing summary', () => {
    beforeEach(done => {
      store.state.paymentMethod.paymentMethodId = 'x';
      vm.cardType = 'Visa';
      vm.lastFourDigits = '4242';
      vm.expirationMonth = 2;
      vm.expirationYear = 20;
      store.state.currentStep = 'next_step';
      Vue.nextTick(done);
    });

    it('should show the credit card details', () => {
      expect(vm.$el.querySelector('.overview div:first-child div:nth-child(1)')).toContainText(
        'Visa',
      );

      expect(vm.$el.querySelector('.overview div:first-child div:nth-child(1)')).toContainHtml(
        'ending in <strong>4242</strong>',
      );

      expect(vm.$el.querySelector('.overview div:first-child div:nth-child(2)')).toHaveText(
        'Exp 2/20',
      );
    });
  });
});
