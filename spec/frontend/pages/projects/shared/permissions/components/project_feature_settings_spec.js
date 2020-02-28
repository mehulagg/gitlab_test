import { mount, shallowMount } from '@vue/test-utils';

import projectFeatureSetting from '~/pages/projects/shared/permissions/components/project_feature_setting.vue';
import projectFeatureToggle from '~/vue_shared/components/toggle_button.vue';

describe('Project Feature Settings', () => {
  const defaultProps = {
    name: 'Test',
    options: [[1, 1], [2, 2], [3, 3], [4, 4], [5, 5]],
    value: 1,
    disabledInput: false,
  };

  describe('Hidden name input', () => {
    it('should set the hidden name input if the name exists', () => {
      const wrapper = shallowMount(projectFeatureSetting, { propsData: defaultProps });

      expect(wrapper.find({ name: 'Test' }).props().value).toBe(1);
    });

    it('should not set the hidden name input if the name does not exist', () => {
      const wrapper = shallowMount(projectFeatureSetting, {
        propsData: { ...defaultProps, name: null },
      });

      expect(wrapper.find({ name: 'Test' }).exists()).toBe(false);
    });
  });

  describe('Feature toggle', () => {
    it('should enable the feature toggle if the value is not 0', () => {
      const wrapper = shallowMount(projectFeatureSetting, { propsData: defaultProps });

      expect(wrapper.find(projectFeatureToggle).props().value).toBe(true);
    });

    it('should enable the feature toggle if the value is less than 0', () => {
      const wrapper = shallowMount(projectFeatureSetting, {
        propsData: { ...defaultProps, value: -1 },
      });

      expect(wrapper.find(projectFeatureToggle).props().value).toBe(true);
    });

    it('should disable the feature toggle if the value is 0', () => {
      const wrapper = shallowMount(projectFeatureSetting, {
        propsData: { ...defaultProps, value: 0 },
      });

      expect(wrapper.find(projectFeatureToggle).props().value).toBe(false);
    });

    it('should disable the feature toggle if disabledInput is set', () => {
      const wrapper = shallowMount(projectFeatureSetting, {
        propsData: { ...defaultProps, disabledInput: true },
      });

      expect(wrapper.find(projectFeatureToggle).props().disabledInput).toBe(true);
    });

    it('should emit a change event when the feature toggle changes', () => {
      const wrapper = mount(projectFeatureSetting, { propsData: defaultProps });

      expect(wrapper.emitted().change).toBeUndefined();
      wrapper
        .find(projectFeatureToggle)
        .find('button')
        .trigger('click');

      return wrapper.vm.$nextTick().then(() => {
        expect(wrapper.emitted().change.length).toBe(1);
        expect(wrapper.emitted().change[0]).toEqual([0]);
      });
    });
  });

  describe('Project repo select', () => {
    it.each`
      disabledInput | value | options                     | isDisabled
      ${true}       | ${0}  | ${[[1, 1]]}                 | ${true}
      ${true}       | ${1}  | ${[[1, 1], [2, 2], [3, 3]]} | ${true}
      ${false}      | ${0}  | ${[[1, 1], [2, 2], [3, 3]]} | ${true}
      ${false}      | ${1}  | ${[[1, 1]]}                 | ${true}
      ${false}      | ${1}  | ${[[1, 1], [2, 2], [3, 3]]} | ${false}
    `(
      'should set disabled to $isDisabled when disabledInput is $disabledInput, the value is $value and options are $options',
      ({ disabledInput, value, options, isDisabled }) => {
        const wrapper = shallowMount(projectFeatureSetting, {
          propsData: { ...defaultProps, disabledInput, value, options },
        });

        if (isDisabled) {
          expect(wrapper.find('select').attributes().disabled).toEqual('disabled');
        } else {
          expect(wrapper.find('select').attributes().disabled).toBeUndefined();
        }
      },
    );

    it('should emit the change when a new option is selected', () => {
      const wrapper = shallowMount(projectFeatureSetting, { propsData: defaultProps });

      expect(wrapper.emitted().change).toBeUndefined();
      wrapper
        .findAll('option')
        .at(1)
        .trigger('change');

      return wrapper.vm.$nextTick().then(() => {
        expect(wrapper.emitted().change.length).toBe(1);
        expect(wrapper.emitted().change[0]).toEqual([2]);
      });
    });
  });
});
