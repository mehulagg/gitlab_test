import { shallowMount } from '@vue/test-utils';
import PolicyPreview from 'ee/threat_monitoring/components/policy_editor/policy_preview.vue';
import { GlTabs } from '@gitlab/ui';

describe('PolicyPreview component', () => {
  let wrapper;

  const factory = ({ propsData } = {}) => {
    wrapper = shallowMount(PolicyPreview, {
      propsData: {
        ...propsData,
      },
    });
  };

  beforeEach(() => {
    factory({
      propsData: {
        policyYaml: 'foo',
        policyDescription: 'bar',
      },
    });
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('renders policy preview tabs', () => {
    expect(wrapper.find(GlTabs).element).toMatchSnapshot();
  });
});
