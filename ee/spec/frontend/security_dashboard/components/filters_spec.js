import Vuex from 'vuex';
import Filters from 'ee/security_dashboard/components/filters.vue';
import createStore from 'ee/security_dashboard/store';
import { mount, createLocalVue } from '@vue/test-utils';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('Filter component', () => {
  let wrapper;
  let store;

  const createWrapper = (props = {}) => {
    wrapper = mount(Filters, {
      localVue,
      store,
      propsData: {
        ...props,
      },
      slots: {
        buttons: '<div class="button-slot"></div>',
      },
    });
  };

  beforeEach(() => {
    store = createStore();
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('severity', () => {
    beforeEach(() => {
      createWrapper();
    });

    it('should display all filters', () => {
      expect(wrapper.findAll('.js-filter')).toHaveLength(3);
    });

    it('should display "Hide dismissed vulnerabilities" toggle', () => {
      expect(wrapper.findAll('.js-toggle')).toHaveLength(1);
    });
  });

  describe('buttons slot', () => {
    it('should exist', () => {
      createWrapper();
      expect(wrapper.find('.button-slot').exists()).toBe(true);
    });
  });
});
