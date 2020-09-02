import { mount, shallowMount } from '@vue/test-utils';

import projectFeatureLabeledToggle from '~/pages/projects/shared/permissions/components/project_feature_labeled_toggle.vue';
import projectFeatureToggle from '~/vue_shared/components/toggle_button.vue';

describe('Project Feature Labeled Toggle', () => {
  const defaultProps = {
    name: 'test',
    label: 'TEST',
    value: true,
    disabledInput: false,
    helpPath: 'HELP PATH'
  };
  let wrapper;

  const mountComponent = customProps => {
    const propsData = { ...defaultProps, ...customProps };
    return shallowMount(projectFeatureLabeledToggle, { propsData });
  };

  beforeEach(() => {
    wrapper = mountComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  describe('Feature label', () => {
    it('should render the correct label', () => {
      expect(wrapper.find("span").element.innerHTML.trim()).toBe(defaultProps.label);
    });
  });

  describe('Feature toggle', () => {
    it('should enable the feature toggle if the value is true', () => {
      wrapper.setProps({ value: true });
      expect(wrapper.find(projectFeatureToggle).props().value).toBe(true);
    });

    it('should disable the feature toggle if the value is false', () => {
      wrapper.setProps({ value: false });

      return wrapper.vm.$nextTick(() => {
        expect(wrapper.find(projectFeatureToggle).props().value).toBe(false);
      });
    });

    it('should disable the feature toggle if disabledInput is set', () => {
      wrapper.setProps({ disabledInput: true });

      return wrapper.vm.$nextTick(() => {
        expect(wrapper.find(projectFeatureToggle).props().disabledInput).toBe(true);
      });
    });

    it('should emit a change event when the feature toggle changes', () => {
      // Needs to be fully mounted to be able to trigger the click event on the internal button
      wrapper = mount(projectFeatureLabeledToggle, { propsData: defaultProps });

      expect(wrapper.emitted().change).toBeUndefined();
      wrapper
        .find(projectFeatureToggle)
        .find('button')
        .trigger('click');

      return wrapper.vm.$nextTick().then(() => {
        expect(wrapper.emitted().change.length).toBe(1);
        expect(wrapper.emitted().change[0]).toEqual([false]);
      });
    });
  });
});
