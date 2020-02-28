import { shallowMount } from '@vue/test-utils';

import projectSettingRow from '~/pages/projects/shared/permissions/components/project_setting_row.vue';

describe('Project Setting Row', () => {
  it('should show the label if it is set', () => {
    const wrapper = shallowMount(projectSettingRow, { propsData: { label: 'Test label' } });

    expect(wrapper.find('label').text()).toEqual('Test label');
  });

  it('should hide the label if it is not set', () => {
    const wrapper = shallowMount(projectSettingRow);

    expect(wrapper.find('label').exists()).toBe(false);
  });

  it('should show the help icon with the correct help path if it is set', () => {
    const wrapper = shallowMount(projectSettingRow, {
      propsData: { label: 'Test label', helpPath: '/123' },
    });
    const link = wrapper.find('a');

    expect(link.exists()).toBe(true);
    expect(link.attributes().href).toEqual('/123');
  });

  it('should hide the help icon if no help path is set', () => {
    const wrapper = shallowMount(projectSettingRow, { propsData: { label: 'Test label' } });

    expect(wrapper.find('a').exists()).toBe(false);
  });

  it('should show the help text if it is set', () => {
    const wrapper = shallowMount(projectSettingRow, { propsData: { helpText: 'Test text' } });

    expect(wrapper.find('span').text()).toEqual('Test text');
  });

  it('should hide the help text if it is set', () => {
    const wrapper = shallowMount(projectSettingRow);

    expect(wrapper.find('span').exists()).toBe(false);
  });
});
