import { mount } from '@vue/test-utils';
import { GlBanner } from '@gitlab/ui';
import AutoFixUserCallout from 'ee/security_dashboard/components/auto_fix_user_callout.vue';

describe('AutoFixUserCallout', () => {
  let wrapper;

  const helpPagePath = '/help/page/path';

  const createWrapper = () => {
    wrapper = mount(AutoFixUserCallout, {
      propsData: {
        helpPagePath,
      },
    });
  };

  it('renders properly', () => {
    createWrapper();

    expect(wrapper.find(GlBanner).exists()).toBe(true);
    expect(wrapper.text()).toContain('Introducing GitLab auto-fix');
    expect(wrapper.text()).toContain('Learn more');
    expect(wrapper.text()).toContain(
      "If you're using dependency and/or container scanning, and auto-fix is enabled, auto-fix automatically creates merge requests with fixes to vulnerabilities.",
    );
    expect(wrapper.html()).toContain(helpPagePath);
  });
});
