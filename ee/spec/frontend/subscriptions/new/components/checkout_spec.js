import Vuex from 'vuex';
import { shallowMount, createLocalVue } from '@vue/test-utils';
import createStore from 'ee/subscriptions/new/store';
import Component from 'ee/subscriptions/new/components/checkout.vue';
import ProgressBar from 'ee/subscriptions/new/components/checkout/progress_bar.vue';

describe('Checkout', () => {
  const localVue = createLocalVue();
  localVue.use(Vuex);

  let store;
  let wrapper;

  const createComponent = () => {
    wrapper = shallowMount(Component, {
      store,
    });
  };

  const findProgressBar = () => wrapper.find(ProgressBar);

  beforeEach(() => {
    store = createStore();
    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  describe('Progress bar', () => {
    describe('for new users', () => {
      beforeEach(() => {
        store.state.newUser = true;
      });

      it('should be shown', () => {
        expect(findProgressBar().exists()).toBe(true);
      });
    });

    describe('for existing users', () => {
      beforeEach(() => {
        store.state.newUser = false;
      });

      it('should be hidden', () => {
        expect(findProgressBar().exists()).toBe(false);
      });
    });
  });
});
