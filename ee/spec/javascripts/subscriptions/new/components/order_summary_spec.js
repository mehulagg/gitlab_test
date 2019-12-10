import Vue from 'vue';
import component from 'ee/pages/subscriptions/new/components/order_summary.vue';
import Store from 'ee/pages/subscriptions/new/stores/subscription_store';
import mockData from '../mock_data.json';
import mountComponent from 'spec/helpers/vue_mount_component_helper';

describe('Order Summary', () => {
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

  describe('Changing the company name', () => {
    describe('When purchasing for a single user', () => {
      beforeEach(done => {
        store.state.subscriptionDetails.setupForCompany = false;
        Vue.nextTick(done);
      });

      it('should display the title with the passed name', () => {
        expect(vm.$el.querySelector('h4')).toContainText("Alex's GitLab subscription");
      });
    });

    describe('When purchasing for a company or group', () => {
      beforeEach(done => {
        store.state.subscriptionDetails.setupForCompany = true;
        Vue.nextTick(done);
      });

      describe('Without a group name provided', () => {
        it('should display the title with the default name', () => {
          expect(vm.$el.querySelector('h4')).toContainText(
            "Your organization's GitLab subscription",
          );
        });
      });

      describe('With a group name provided', () => {
        beforeEach(done => {
          store.state.subscriptionDetails.organizationName = 'My group';
          Vue.nextTick(done);
        });

        it('when given a group name, it should display the title with the group name', () => {
          expect(vm.$el.querySelector('h4')).toContainText("My group's GitLab subscription");
        });
      });
    });
  });

  describe('Changing the plan', () => {
    describe('the clicked on plan', () => {
      it('should display the chosen plan', () => {
        expect(vm.$el.querySelector('.selected-plan')).toContainText('Gold plan');
      });

      it('should display the correct formatted amount price per user', () => {
        expect(vm.$el.querySelector('.per-user')).toContainText('$1,188 per user per year');
      });
    });

    describe('the default plan', () => {
      beforeEach(done => {
        store.state.subscriptionDetails.selectedPlan = 'bronze_plan_id';
        store.state.subscriptionDetails.numberOfUsers = 1;
        Vue.nextTick(done);
      });

      it('should display the chosen plan', () => {
        expect(vm.$el.querySelector('.selected-plan')).toContainText('Bronze plan');
      });

      it('should display the correct formatted amount price per user', () => {
        expect(vm.$el.querySelector('.per-user')).toContainText('$48 per user per year');
      });

      it('should display the correct formatted total amount', () => {
        expect(vm.$el.querySelector('.total-amount')).toContainText('$48');
      });
    });
  });

  describe('Changing the number of users', () => {
    beforeEach(done => {
      store.state.subscriptionDetails.selectedPlan = 'gold_plan_id';
      store.state.subscriptionDetails.numberOfUsers = 1;
      Vue.nextTick(done);
    });

    describe('the default of 1 selected user', () => {
      it('should display the correct number of users', () => {
        expect(vm.$el.querySelector('.number-of-users')).toContainText('(x1)');
      });

      it('should display the correct formatted amount price per user', () => {
        expect(vm.$el.querySelector('.per-user')).toContainText('$1,188 per user per year');
      });

      it('should display the correct multiplied formatted amount of the chosen plan', () => {
        expect(vm.$el.querySelector('.amount')).toContainText('$1,188');
      });

      it('should display the correct formatted total amount', () => {
        expect(vm.$el.querySelector('.total-amount')).toContainText('$1,188');
      });
    });

    describe('3 selected users', () => {
      beforeEach(done => {
        store.state.subscriptionDetails.selectedPlan = 'gold_plan_id';
        store.state.subscriptionDetails.numberOfUsers = 3;
        Vue.nextTick(done);
      });

      it('should display the correct number of users', () => {
        expect(vm.$el.querySelector('.number-of-users')).toContainText('(x3)');
      });

      it('should display the correct formatted amount price per user', () => {
        expect(vm.$el.querySelector('.per-user')).toContainText('$1,188 per user per year');
      });

      it('should display the correct multiplied formatted amount of the chosen plan', () => {
        expect(vm.$el.querySelector('.amount')).toContainText('$3,564');
      });

      it('should display the correct formatted total amount', () => {
        expect(vm.$el.querySelector('.total-amount')).toContainText('$3,564');
      });
    });

    describe('no selected users', () => {
      beforeEach(done => {
        store.state.subscriptionDetails.selectedPlan = 'gold_plan_id';
        store.state.subscriptionDetails.numberOfUsers = 0;
        Vue.nextTick(done);
      });

      it('should not display the number of users', () => {
        expect(vm.$el.querySelector('.number-of-users')).toBeNull();
      });

      it('should display the correct formatted amount price per user', () => {
        expect(vm.$el.querySelector('.per-user')).toContainText('$1,188 per user per year');
      });

      it('should not display the amount', () => {
        expect(vm.$el.querySelector('.amount')).toContainText('-');
      });

      it('should display the correct formatted total amount', () => {
        expect(vm.$el.querySelector('.total-amount')).toContainText('-');
      });
    });

    describe('date range', () => {
      beforeEach(done => {
        store.state.orderSummary.startDate = new Date('2019-12-05');
        Vue.nextTick(done);
      });

      it('shows the formatted date range from the start date to one year in the future', () => {
        expect(vm.$el.querySelector('.dates')).toContainText('Dec 5, 2019 - Dec 5, 2020');
      });
    });

    describe('tax rate', () => {
      describe('a tax rate of 0', () => {
        beforeEach(done => {
          store.state.orderSummary.taxRate = 0;
          Vue.nextTick(done);
        });

        it('should not display the total amount excluding vat if the tax rate is 0', () => {
          expect(vm.$el.querySelector('.total-ex-vat')).toBeNull();
        });

        it('should not display the vat amount if the tax rate is 0', () => {
          expect(vm.$el.querySelector('.vat')).toBeNull();
        });
      });

      describe('a tax rate of 8%', () => {
        beforeEach(done => {
          store.state.orderSummary.taxRate = 0.08;
          Vue.nextTick(done);
        });

        it('should display the total amount excluding vat if the tax rate is 0', () => {
          expect(vm.$el.querySelector('.total-ex-vat')).toContainText('$1,188');
        });

        it('should display the vat amount if the tax rate is 0', () => {
          expect(vm.$el.querySelector('.vat')).toContainText('$95.04');
        });

        it('should display the total amount including the vat', () => {
          expect(vm.$el.querySelector('.total-amount')).toContainText('$1,283.04');
        });
      });
    });
  });
});
