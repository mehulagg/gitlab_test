import { shallowMount } from '@vue/test-utils';
import ToggleButton from '~/vue_shared/components/toggle_button.vue';
import { GlIcon } from '@gitlab/ui';

describe('Toggle Button component', () => {
  let wrapper;

  function createComponent(propsData = {}) {
    wrapper = shallowMount(ToggleButton, {
      propsData,
    });
  }

  it('renders input with provided name', () => {
    createComponent({
      name: 'foo',
    });
    expect(wrapper.find('input').attributes('name')).toBe('foo');
  });

  describe('when value is true', () => {
    beforeEach(() => {
      createComponent({
        value: true,
        name: 'foo',
      });
    });

    it('renders input with value=true', () => {
      expect(wrapper.find('input').attributes('value')).toBe('true');
    });

    it('renders input status icon', () => {
      const icon = wrapper.find(GlIcon);
      expect(icon.exists()).toBe(true);
      expect(icon.props('name')).toBe('status_success_borderless');
    });

    it('renders is-checked class', () => {
      expect(wrapper.find('button').classes()).toContain('is-checked');
    });

    it('emits change event correctly when clicked', async () => {
      wrapper.find('button').trigger('click');
      await wrapper.vm.$nextTick();

      const changeEvents = wrapper.emitted('change');
      expect(changeEvents).toBeTruthy();
      expect(changeEvents).toHaveLength(1);
      expect(changeEvents[0]).toEqual([false]);
    });
  });

  describe('when value is false', () => {
    beforeEach(() => {
      createComponent({
        value: false,
        name: 'foo',
      });
    });

    it('renders input with value=false', () => {
      expect(wrapper.find('input').attributes('value')).toBe('false');
    });

    it('renders input status icon', () => {
      const icon = wrapper.find(GlIcon);
      expect(icon.exists()).toBe(true);
      expect(icon.props('name')).toBe('status_failed_borderless');
    });

    it('does not render is-checked class', () => {
      expect(wrapper.find('button').classes()).not.toContain('is-checked');
    });

    it('emits change event correctly when clicked', async () => {
      wrapper.find('button').trigger('click');
      await wrapper.vm.$nextTick();

      const changeEvents = wrapper.emitted('change');
      expect(changeEvents).toBeTruthy();
      expect(changeEvents).toHaveLength(1);
      expect(changeEvents[0]).toEqual([true]);
    });
  });

  describe('when disabledInput is true', () => {
    beforeEach(() => {
      createComponent({
        value: true,
        disabledInput: true,
      });
    });

    it('renders disabled button', () => {
      expect(wrapper.find('button').classes()).toContain('is-disabled');
    });

    it('does not emit change event when clicked', async () => {
      wrapper.find('button').trigger('click');
      await wrapper.vm.$nextTick();

      expect(wrapper.emitted('change')).toBeFalsy();
    });
  });

  describe('when isLoading is true', () => {
    beforeEach(() => {
      createComponent({
        value: true,
        isLoading: true,
      });
    });

    it('renders loading class', () => {
      expect(wrapper.find('button').classes()).toContain('is-loading');
    });
  });
});
