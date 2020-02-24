import { shallowMount } from '@vue/test-utils';
import { GlButton } from '@gitlab/ui';
import StatusPageSettingsForm from 'ee/status_page_settings/components/settings_form.vue';
import createStore from 'ee/status_page_settings/store';

describe('Status Page settings form', () => {
  let wrapper;
  const store = createStore();

  beforeEach(() => {
    wrapper = shallowMount(StatusPageSettingsForm, { store });
  });

  afterEach(() => {
    if (wrapper) {
      wrapper.destroy();
    }
  });

  describe('default state', () => {
    it('should match the default snapshot', () => {
      expect(wrapper.element).toMatchSnapshot();
    });
  });

  it('renders header text', () => {
    expect(wrapper.find('.js-section-header').text()).toBe('Status Page');
  });

  describe('expand/collapse button', () => {
    it('renders as an expand button by default', () => {
      expect(wrapper.find('.js-settings-toggle').text()).toBe('Expand');
    });
  });

  describe('sub-header', () => {
    it('renders descriptive text', () => {
      expect(wrapper.find('.js-section-sub-header').text()).toContain(
        'Configure file storage settings to link issues in this project to an external status page.',
      );
    });
  });

  describe('form', () => {
    beforeEach(() => {
      jest.spyOn(wrapper.vm, 'updateStatusPageSettings').mockImplementation();
    });

    describe('submit button', () => {
      const findSubmitButton = () => wrapper.find('.settings-content form').find(GlButton);

      it('submits form on click', () => {
        findSubmitButton(wrapper).vm.$emit('click');
        expect(wrapper.vm.updateStatusPageSettings).toHaveBeenCalled();
      });
    });
  });
});
