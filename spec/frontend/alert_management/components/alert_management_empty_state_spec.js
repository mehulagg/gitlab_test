import { mount } from '@vue/test-utils';
import { GlEmptyState, GlButton } from '@gitlab/ui';
import AlertManagementEmptyState from '~/alert_management/components/alert_management_empty_state.vue';

describe('AlertManagementEmptyState', () => {
  let wrapper;

  function mountComponent({
    props = {
      alertManagementEnabled: false,
      userCanEnableAlertManagement: false,
    },
    stubs = {},
  } = {}) {
    wrapper = mount(AlertManagementEmptyState, {
      propsData: {
        enableAlertManagementPath: '/link',
        emptyAlertSvgPath: 'illustration/path',
        ...props,
      },
      stubs,
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

  const EmptyState = () => wrapper.find(GlEmptyState);

  describe('Empty state', () => {
    it('shows empty state', () => {
      expect(EmptyState().exists()).toBe(true);
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
        EmptyState()
          .find(GlButton)
          .attributes('href'),
      ).toBe('https://opsgenie-url.com');
    });
  });
});
