import Vue from 'vue';
import component from 'ee/pages/subscriptions/new/components/checkout/billing_address.vue';
import Store from 'ee/pages/subscriptions/new/stores/subscription_store';
import mountComponent from 'spec/helpers/vue_mount_component_helper';

describe('Billing Address', () => {
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

  describe('Displaying countries in select', () => {
    beforeEach(done => {
      vm.countryOptions = [
        { text: 'Please select a country', value: null },
        { text: 'Netherlands', value: 'NL' },
      ];
      Vue.nextTick(done);
    });

    it('should display the select prompt and the countries returned from the server', () => {
      expect(vm.$el.querySelector('#country')).toHaveHtml(
        '<option value="">Please select a country</option><option value="NL">Netherlands</option>',
      );
    });
  });

  describe('Selecting a country', () => {
    it('clears the selected state', () => {
      store.state.billingAddress.state = 'UT';
      vm.countryChanged();

      expect(store.state.billingAddress.state).toBeNull();
    });
  });

  describe('Validations', () => {
    beforeEach(() => {
      store.state.billingAddress.country = 'NL';
      store.state.billingAddress.streetAddressLine1 = 'address line 1';
      store.state.billingAddress.city = 'city';
      store.state.billingAddress.zipCode = 'zip';
    });

    it('should be valid when country, streetAddressLine1, city and zipCode have been entered', () => {
      expect(vm.isValid).toBeTruthy();
    });

    it('should be invalid when country is undefined', () => {
      store.state.billingAddress.country = undefined;

      expect(vm.isValid).toBeFalsy();
    });

    it('should be invalid when streetAddressLine1 is undefined', () => {
      store.state.billingAddress.streetAddressLine1 = undefined;

      expect(vm.isValid).toBeFalsy();
    });

    it('should be invalid when city is undefined', () => {
      store.state.billingAddress.city = undefined;

      expect(vm.isValid).toBeFalsy();
    });

    it('should be invalid when zipCode is undefined', () => {
      store.state.billingAddress.zipCode = undefined;

      expect(vm.isValid).toBeFalsy();
    });
  });

  describe('Showing summary', () => {
    beforeEach(done => {
      store.state.billingAddress.country = 'NL';
      store.state.billingAddress.streetAddressLine1 = 'address line 1';
      store.state.billingAddress.streetAddressLine2 = 'address line 2';
      store.state.billingAddress.city = 'city';
      store.state.billingAddress.state = 'state';
      store.state.billingAddress.zipCode = 'zip';
      store.state.currentStep = 'next_step';
      Vue.nextTick(done);
    });

    it('should show the entered address', () => {
      expect(vm.$el.querySelector('.overview div:first-child div:nth-child(1)')).toHaveText(
        'address line 1',
      );

      expect(vm.$el.querySelector('.overview div:first-child div:nth-child(2)')).toHaveText(
        'address line 2',
      );

      expect(vm.$el.querySelector('.overview div:first-child div:nth-child(3)')).toHaveText(
        'city, state zip',
      );
    });
  });
});
