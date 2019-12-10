import Vue from 'vue';
import component from 'ee/pages/subscriptions/new/components/checkout/components/step.vue';
import Store from 'ee/pages/subscriptions/new/stores/subscription_store';
import mountComponent from 'spec/helpers/vue_mount_component_helper';

describe('Payment Method', () => {
  let vm;
  let props;
  const store = new Store();
  const step = 'step_2';
  const title = 'step title';
  const isValid = true;
  const nextStepButtonText = 'next step';
  const Component = Vue.extend(component);

  beforeEach(() => {
    props = { store, step, title, isValid, nextStepButtonText };
    vm = mountComponent(Component, props);
  });

  afterEach(() => {
    vm.$destroy();
  });

  describe('isActive', () => {
    it('should return true when this step is the current step', () => {
      store.state.currentStep = 'step_2';

      expect(vm.isActive).toBeTruthy();
    });

    it('should return false when this step is not the current step', () => {
      store.state.currentStep = 'step_1';

      expect(vm.isActive).toBeFalsy();
    });
  });

  describe('isFinished', () => {
    it('should return true when this step is valid and not active', () => {
      vm.isValid = true;
      store.state.currentStep = 'step_1';

      expect(vm.isFinished).toBeTruthy();
    });

    it('should return false when this step is not valid and not active', () => {
      vm.isValid = false;
      store.state.currentStep = 'step_1';

      expect(vm.isFinished).toBeFalsy();
    });

    it('should return false when this step is valid and active', () => {
      vm.isValid = true;
      store.state.currentStep = 'step_2';

      expect(vm.isFinished).toBeFalsy();
    });

    it('should return false when this step is not valid and active', () => {
      vm.isValid = false;
      store.state.currentStep = 'step_2';

      expect(vm.isFinished).toBeFalsy();
    });
  });

  describe('editable', () => {
    it('should return true when this step is finished and comes before the current step', () => {
      vm.isValid = true;
      vm.step = 'paymentMethod';
      store.state.currentStep = 'confirmOrder';

      expect(vm.editable).toBeTruthy();
    });

    it('should return false when this step is not finished and comes before the current step', () => {
      vm.isValid = false;
      vm.step = 'paymentMethod';
      store.state.currentStep = 'confirmOrder';

      expect(vm.editable).toBeFalsy();
    });

    it('should return false when this step is finished and does not come before the current step', () => {
      vm.isValid = true;
      vm.step = 'paymentMethod';
      store.state.currentStep = 'paymentMethod';

      expect(vm.editable).toBeFalsy();
    });
  });

  describe('Showing the summary', () => {
    it('shows the summary when this step is finished', () => {
      vm.isValid = true;
      store.state.currentStep = 'step_1';

      expect(vm.$el.querySelector('.overview')).toExist();
    });

    it('does not show the summary when this step is not finished', done => {
      vm.isValid = true;
      store.state.currentStep = 'step_2';

      Vue.nextTick(() => {
        expect(vm.$el.querySelector('.overview')).not.toExist();
        done();
      });
    });
  });

  describe('Next button', () => {
    it('shows the next button when the text was passed', () => {
      expect(vm.$el.querySelector('.btn')).toHaveText('next step');
    });

    it('does not show the next button when no text was passed', done => {
      vm.nextStepButtonText = undefined;

      Vue.nextTick(() => {
        expect(vm.$el.querySelector('.btn')).not.toExist();
        done();
      });
    });

    it('is disabled when this step is not valid', done => {
      vm.isValid = false;

      Vue.nextTick(() => {
        expect(vm.$el.querySelector('.btn')).toBeDisabled();
        done();
      });
    });

    it('is enabled when this step is valid', done => {
      vm.isValid = true;

      Vue.nextTick(() => {
        expect(vm.$el.querySelector('.btn')).not.toBeDisabled();
        done();
      });
    });
  });
});
