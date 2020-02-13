import Vuex from 'vuex';
import { shallowMount, createLocalVue } from '@vue/test-utils';

import DropdownValue from '~/vue_shared/components/sidebar/labels_select_vue/dropdown_value.vue';
import DropdownValueRegularLabel from '~/vue_shared/components/sidebar/labels_select/dropdown_value_regular_label.vue';
import DropdownValueScopedLabel from '~/vue_shared/components/sidebar/labels_select/dropdown_value_scoped_label.vue';

import createDefaultStore from '~/vue_shared/components/sidebar/labels_select_vue/store';

import { mockConfig, mockRegularLabel, mockScopedLabel } from './mock_data';

const localVue = createLocalVue();
localVue.use(Vuex);

const createComponent = (initialState = mockConfig, slots = {}) => {
  const store = createDefaultStore();

  store.dispatch('setInitialState', initialState);

  return shallowMount(DropdownValue, {
    localVue,
    store,
    slots,
  });
};

describe('DropdownValue', () => {
  let wrapper;

  beforeEach(() => {
    wrapper = createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  describe('methods', () => {
    describe('labelFilterUrl', () => {
      it('returns a label filter URL based on provided label param', () => {
        expect(wrapper.vm.labelFilterUrl(mockRegularLabel)).toBe(
          '/gitlab-org/my-project/issues?label_name[]=Foo%20Label',
        );
      });
    });

    describe('labelStyle', () => {
      it('returns an object containing `color` & `backgroundColor` based on provided label param', () => {
        expect(wrapper.vm.labelStyle(mockRegularLabel)).toEqual(
          expect.objectContaining({
            color: '#FFFFFF',
            backgroundColor: '#BADA55',
          }),
        );
      });
    });

    describe('getDropdownLabelComponent', () => {
      it('returns string `dropdown-value-scoped-label` when provided label param is a scoped label', () => {
        expect(wrapper.vm.getDropdownLabelComponent(mockScopedLabel)).toBe(
          'dropdown-value-scoped-label',
        );
      });

      it('returns string `dropdown-value-regular-label` when provided label param is a regular label', () => {
        expect(wrapper.vm.getDropdownLabelComponent(mockRegularLabel)).toBe(
          'dropdown-value-regular-label',
        );
      });
    });
  });

  describe('template', () => {
    it('renders class `has-labels` on component container element when `selectedLabels` is not empty', () => {
      expect(wrapper.attributes('class')).toContain('has-labels');
    });

    it('renders element containing `None` when `selectedLabels` is empty', () => {
      const wrapperNoLabels = createComponent(
        {
          ...mockConfig,
          selectedLabels: [],
        },
        {
          default: 'None',
        },
      );
      const noneEl = wrapperNoLabels.find('span.text-secondary');

      expect(noneEl.exists()).toBe(true);
      expect(noneEl.text()).toBe('None');

      wrapperNoLabels.destroy();
    });

    it('renders labels when `selectedLabels` is not empty', () => {
      expect(wrapper.find(DropdownValueRegularLabel).exists()).toBe(true);
      expect(wrapper.find(DropdownValueScopedLabel).exists()).toBe(true);
    });
  });
});
