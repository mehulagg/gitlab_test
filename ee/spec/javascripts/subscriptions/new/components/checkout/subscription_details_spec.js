import Vue from 'vue';
import component from 'ee/pages/subscriptions/new/components/checkout/subscription_details.vue';
import Store from 'ee/pages/subscriptions/new/stores/subscription_store';
import mockData from '../../mock_data.json';
import mountComponent from 'spec/helpers/vue_mount_component_helper';

describe('Subscription Details', () => {
  let vm;
  let props;
  const store = new Store();
  store.setInitialData(mockData);
  const Component = Vue.extend(component);

  beforeEach(() => {
    props = { store };
    vm = mountComponent(Component, props);
  });

  afterEach(() => {
    vm.$destroy();
  });

  describe('Setting up for personal use', () => {
    beforeEach(() => {
      store.state.subscriptionDetails.setupForCompany = false;
    });

    it('should be valid', () => {
      expect(vm.isValid).toBeTruthy();
    });

    it('should not display an input field for the company or group name', () => {
      expect(vm.$el.querySelector('#organizationName')).not.toExist();
    });

    it('should disable the number of users input field', () => {
      expect(vm.$el.querySelector('#numberOfUsers')).toBeDisabled();
    });

    it('should show a link to change to setting up for a company', () => {
      expect(vm.$el.querySelector('.company-link')).toContainText(
        'Need more users? Purchase GitLab for your company or team.',
      );
    });
  });

  describe('Clicking the link to set up for a company or group', () => {
    beforeEach(() => {
      store.state.subscriptionDetails.setupForCompany = false;
      vm.$el.querySelector('.company-link a').click();
    });

    it('should update the state', () => {
      expect(store.state.subscriptionDetails.setupForCompany).toBeTruthy();
    });
  });

  describe('Setting up for a company or group', () => {
    beforeEach(() => {
      store.state.subscriptionDetails.setupForCompany = true;
    });

    it('should be invalid', () => {
      expect(vm.isValid).toBeFalsy();
    });

    it('should display an input field for the company or group name', () => {
      expect(vm.$el.querySelector('#organizationName')).toExist();
    });

    it('should enable the number of users input field', () => {
      expect(vm.$el.querySelector('#numberOfUsers')).not.toBeDisabled();
    });

    it('should not show the link to change to setting up for a company', () => {
      expect(vm.$el.querySelector('.company-link')).not.toExist();
    });

    describe('filling in the company name and the number of users', () => {
      it('should make the component valid', () => {
        store.state.subscriptionDetails.organizationName = 'My Organization';
        store.state.subscriptionDetails.numberOfUsers = 2;

        expect(vm.isValid).toBeTruthy();
      });
    });
  });

  describe('Showing summary', () => {
    beforeEach(done => {
      store.state.subscriptionDetails.setupForCompany = true;
      store.state.subscriptionDetails.selectedPlan = 'silver_plan_id';
      store.state.subscriptionDetails.organizationName = 'group_name';
      store.state.subscriptionDetails.numberOfUsers = 25;
      store.state.currentStep = 'next_step';
      Vue.nextTick(done);
    });

    it('should show the selected plan in bold, the group name and the number of users', () => {
      expect(vm.$el.querySelector('.overview div:first-child strong')).toHaveText('Silver plan');

      expect(vm.$el.querySelector('.overview div:first-child div:nth-child(2)')).toHaveText(
        'Group: group_name',
      );

      expect(vm.$el.querySelector('.overview div:first-child div:nth-child(3)')).toHaveText(
        'Users: 25',
      );
    });
  });
});
