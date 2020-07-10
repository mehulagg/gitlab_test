import { shallowMount } from '@vue/test-utils';
import { GlEmptyState, GlButton } from '@gitlab/ui';
import AlertManagementEmptyState from '~/alert_management/components/alert_management_empty_state.vue';

describe('AlertManagementEmptyState', () => {
  let wrapper;

  function mountComponent({
    props = {
      alertManagementEnabled: false,
      userCanEnableAlertManagement: false,
    },
    stubs = {}
  } = {}) {
    wrapper = shallowMount(AlertManagementEmptyState, {
      propsData: {
        enableAlertManagementPath: '/link',
        emptyAlertSvgPath: 'illustration/path',
        ...props,
      },
      stubs
    });
  }

  beforeEach(() => {
    mountComponent();
  });

  afterEach(() => {
    if (wrapper) {
      wrapper.destroy();
    }
  });

  describe('Empty state', () => {
    it('shows empty state', () => {
      expect(wrapper.find(GlEmptyState).exists()).toBe(true);
    });

    it('show default empty state when OpsGenie mcv is false', () => {
      mountComponent({
        props: {
          alertManagementEnabled: false,
          userCanEnableAlertManagement: false,
        },
      });
      expect(
        wrapper
          .find(GlButton)
          .attributes('href'),
      ).toBe('/link');
    });

    it('show OpsGenie integration state when OpsGenie mcv is true', () => {
      mountComponent({
        props: {
          alertManagementEnabled: false,
          userCanEnableAlertManagement: false,
          opsgenieMvcEnabled: true,
          opsgenieMvcTargetUrl: 'https://opsgenie-url.com',
        },
      });
      expect(
        wrapper
          .find(GlButton)
          .attributes('href'),
      ).toBe('https://opsgenie-url.com');
    });
  });
});
