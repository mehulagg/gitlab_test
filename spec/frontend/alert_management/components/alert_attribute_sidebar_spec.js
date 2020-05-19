import { mount } from '@vue/test-utils';
import { GlDropdownItem } from '@gitlab/ui';
import AlertAttributeSidebar from '~/alert_management/components/alert_attribute_sidebar.vue';
import updateAlertStatus from '~/alert_management/graphql/mutations/update_alert_status.graphql';
import createFlash from '~/flash';
import mockAlerts from '../mocks/alerts.json';

const mockAlert = mockAlerts[0];
jest.mock('~/flash');

describe('Alert Details Sidebar', () => {
  let wrapper;
  const findStatusDropdownItem = () => wrapper.find(GlDropdownItem);

  function mountComponent({
    data,
    sidebarCollapsed = true,
    loading = false,
    mountMethod = mount,
    stubs = {},
  } = {}) {
    wrapper = mountMethod(AlertAttributeSidebar, {
      propsData: {
        alert: { ...mockAlert },
        ...data,
        sidebarCollapsed,
        projectPath: 'projectPath',
      },
      mocks: {
        $apollo: {
          mutate: jest.fn(),
          queries: {
            alert: {
              loading,
            },
          },
        },
      },
      stubs,
    });
  }

  afterEach(() => {
    if (wrapper) {
      wrapper.destroy();
    }
  });

  describe('updating the alert status', () => {
    const mockUpdatedMutationResult = {
      data: {
        updateAlertStatus: {
          errors: [],
          alert: {
            status: 'acknowledged',
          },
        },
      },
    };

    beforeEach(() => {
      mountComponent({
        data: { alert: mockAlert },
        sidebarCollapsed: false,
        loading: false,
      });
    });

    it('calls `$apollo.mutate` with `updateAlertStatus` mutation and variables containing `iid`, `status`, & `projectPath`', () => {
      jest.spyOn(wrapper.vm.$apollo, 'mutate').mockResolvedValue(mockUpdatedMutationResult);
      findStatusDropdownItem().vm.$emit('click');

      expect(wrapper.vm.$apollo.mutate).toHaveBeenCalledWith({
        mutation: updateAlertStatus,
        variables: {
          iid: '1527542',
          status: 'TRIGGERED',
          projectPath: 'projectPath',
        },
      });
    });

    it('calls `createFlash` when request fails', () => {
      jest.spyOn(wrapper.vm.$apollo, 'mutate').mockReturnValue(Promise.reject(new Error()));
      findStatusDropdownItem().vm.$emit('click');

      setImmediate(() => {
        expect(createFlash).toHaveBeenCalledWith(
          'There was an error while updating the status of the alert. Please try again.',
        );
      });
    });
  });
});
