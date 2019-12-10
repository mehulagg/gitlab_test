import Store from 'ee/pages/subscriptions/new/stores/subscription_store';
import mockData from './mock_data.json';

describe('Subscription Store', () => {
  let store;
  beforeEach(() => {
    store = new Store();
  });

  describe('confirmOrderParams', () => {
    it('should return an object with parameters for submitting to the backend', () => {
      store.setInitialData(mockData);
      store.state.billingAddress.country = 'NL';
      store.state.billingAddress.streetAddressLine1 = 'Address line 1';
      store.state.billingAddress.streetAddressLine2 = 'Address line 2';
      store.state.billingAddress.city = 'City';
      store.state.billingAddress.state = 'Utrecht';
      store.state.billingAddress.zipCode = '3563 HC';
      store.state.subscriptionDetails.organizationName = 'GitLab';
      store.state.paymentMethod.paymentMethodId = '2c92c0f86ec95c0c016ed1deed5251fd';

      expect(store.confirmOrderParams()).toEqual({
        setup_for_company: false,
        customer: {
          country: 'NL',
          address_1: 'Address line 1',
          address_2: 'Address line 2',
          city: 'City',
          state: 'Utrecht',
          zip_code: '3563 HC',
          company: 'GitLab',
        },
        subscription: {
          plan_id: 'gold_plan_id',
          payment_method_id: '2c92c0f86ec95c0c016ed1deed5251fd',
          quantity: 1,
        },
      });
    });
  });

  describe('setInitialData', () => {
    describe('parsing setupForCompany to a boolean', () => {
      it('parses "true" string', () => {
        store.setInitialData({ ...mockData, setupForCompany: 'true' });

        expect(store.state.subscriptionDetails.setupForCompany).toBeTruthy();
      });

      it('parses "false" string', () => {
        store.setInitialData({ ...mockData, setupForCompany: 'false' });

        expect(store.state.subscriptionDetails.setupForCompany).toBeFalsy();
      });

      it('parses undefined value', () => {
        store.setInitialData({ ...mockData, setupForCompany: undefined });

        expect(store.state.subscriptionDetails.setupForCompany).toBeFalsy();
      });
    });

    it('sets the fullname', () => {
      store.setInitialData({ ...mockData, fullName: 'Alex Buijs' });

      expect(store.state.subscriptionDetails.fullName).toEqual('Alex Buijs');
    });

    describe('setting the plans', () => {
      it('when providing an empty value it, parses the JSON', () => {
        store.setInitialData({ ...mockData, planData: '[]' });

        expect(store.state.subscriptionDetails.availablePlans).toEqual([]);
      });

      describe('transforming the attributes', () => {
        beforeEach(() => {
          store.setInitialData({
            ...mockData,
            planData: '[{"id": "bronze_plan_id", "code": "bronze", "price_per_year": 48.0}]',
          });
        });

        it('renames the "id" key to "value"', () => {
          expect(store.state.subscriptionDetails.availablePlans[0].value).toEqual('bronze_plan_id');
        });

        it('renames the "code" key to "text" and capitalizes the first character of the value', () => {
          expect(store.state.subscriptionDetails.availablePlans[0].text).toEqual('Bronze');
        });

        it('renames the "price_per_year" key to "pricePerUserPerYear"', () => {
          expect(store.state.subscriptionDetails.availablePlans[0].pricePerUserPerYear).toEqual(48);
        });
      });
    });

    describe('setting the selected plan', () => {
      it('sets the passed plan if it is available', () => {
        store.setInitialData({ ...mockData, planId: 'silver_plan_id' });

        expect(store.state.subscriptionDetails.selectedPlan).toEqual('silver_plan_id');
      });

      it('sets the default plan when no planId is passed', () => {
        store.setInitialData({ ...mockData, planId: undefined });

        expect(store.state.subscriptionDetails.selectedPlan).toEqual('bronze_plan_id');
      });

      it('sets the default plan if passed plan is not available', () => {
        store.setInitialData({ ...mockData, planId: 'unavailable_plan_id' });

        expect(store.state.subscriptionDetails.selectedPlan).toEqual('bronze_plan_id');
      });

      it('sets an empty string if there is no default plan and passed plan is not available', () => {
        store.setInitialData({ ...mockData, planData: '[]', planId: undefined });

        expect(store.state.subscriptionDetails.selectedPlan).toEqual('');
      });
    });

    describe('setting the number of users', () => {
      it('sets the number of users to 1 when not setting up for a company', () => {
        store.setInitialData({ ...mockData, setupForCompany: 'false' });

        expect(store.state.subscriptionDetails.numberOfUsers).toEqual(1);
      });

      it('does not set the number of users when setting up for a company', () => {
        store.setInitialData({ ...mockData, setupForCompany: 'true' });

        expect(store.state.subscriptionDetails.numberOfUsers).toEqual(0);
      });
    });
  });

  describe('getSelectedPlan', () => {
    it('returns the plan that is currently selected', () => {
      store.setInitialData({ ...mockData, planId: 'silver_plan_id' });

      expect(store.getSelectedPlan().text).toEqual('Silver');
    });
  });

  describe('activateStep', () => {
    it('sets the current active step', () => {
      store.activateStep('paymentMethod');

      expect(store.state.currentStep).toEqual('paymentMethod');
    });

    it('does not change the current active step when step is unavailable', () => {
      store.activateStep('unavailable_step');

      expect(store.state.currentStep).toEqual('subscriptionDetails');
    });
  });

  describe('nextStep', () => {
    it('sets the next step as current', () => {
      store.state.currentStep = 'paymentMethod';
      store.nextStep();

      expect(store.state.currentStep).toEqual('confirmOrder');
    });

    it('does not change the current step when current step is last', () => {
      store.state.currentStep = 'confirmOrder';
      store.nextStep();

      expect(store.state.currentStep).toEqual('confirmOrder');
    });
  });

  describe('activeStepIndex', () => {
    it('returns the index of the current active step', () => {
      store.state.currentStep = 'paymentMethod';

      expect(store.activeStepIndex()).toEqual(2);
    });
  });
});
