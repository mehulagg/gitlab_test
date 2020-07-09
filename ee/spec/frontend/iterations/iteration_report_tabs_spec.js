import IterationReportTabs from 'ee/iterations/components/iteration_report_tabs.vue';
import { shallowMount } from '@vue/test-utils';
import { GlAlert, GlLoadingIcon, GlTable, GlTab, GlTabs } from '@gitlab/ui';

describe('Iterations report tabs', () => {
  let wrapper;
  const defaultProps = {
    groupPath: 'gitlab-org',
    iterationId: '3',
  };

  const mountComponent = ({ props = defaultProps, loading = false, data = {} } = {}) => {
    wrapper = shallowMount(IterationReportTabs, {
      propsData: props,
      data() {
        return data;
      },
      mocks: {
        $apollo: {
          queries: { issues: { loading } },
        },
      },
      stubs: {
        GlLoadingIcon,
        GlTab,
        GlTabs,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('shows spinner while loading', () => {
    mountComponent({
      loading: true,
    });

    expect(wrapper.find(GlLoadingIcon).exists()).toBe(true);
    expect(wrapper.find(GlTable).exists()).toBe(false);
  });

  it('shows iterations list when not loading', () => {
    mountComponent({
      loading: false,
    });

    expect(wrapper.find(GlLoadingIcon).exists()).toBe(false);
    expect(wrapper.find(GlTable).exists()).toBe(true);
  });

  it('shows error in a gl-alert', () => {
    const error = 'Oh no!';

    mountComponent({
      data: {
        error,
      },
    });

    expect(wrapper.find(GlAlert).text()).toContain(error);
  });
});
