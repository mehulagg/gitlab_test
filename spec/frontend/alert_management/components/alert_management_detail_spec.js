import { shallowMount } from '@vue/test-utils';
import { GlAlert, GlDropdown, GlDropdownItem, GlLoadingIcon } from '@gitlab/ui';
import createFlash from '~/flash';
import AlertDetails from '~/alert_management/components/alert_details.vue';
import updateAlertStatus from '~/alert_management/graphql/mutations/update_alert_status.graphql';

import mockAlerts from '../mocks/alerts.json';

jest.mock('~/flash');

const mockAlert = mockAlerts[0];

describe('AlertDetails', () => {
  let wrapper;
  const newIssuePath = 'root/alerts/-/issues/new';

  function mountComponent({
    data = { alert: {} },
    createIssueFromAlertEnabled = false,
    loading = false,
  } = {}) {
    wrapper = shallowMount(AlertDetails, {
      propsData: {
        alertId: 'alertId',
        projectPath: 'gitlab-org/gitlab',
        newIssuePath,
      },
      data() {
        return data;
      },
      provide: {
        glFeatures: { createIssueFromAlertEnabled },
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
    });
  }

  afterEach(() => {
    if (wrapper) {
      wrapper.destroy();
    }
  });

  const findCreatedIssueBtn = () => wrapper.find('[data-testid="createIssueBtn"]');
  const findStatusDropdown = () => wrapper.find(GlDropdown);
  const findFirstStatusOption = () => findStatusDropdown().find(GlDropdownItem);

  describe('Alert details', () => {
    describe('when alert is null', () => {
      beforeEach(() => {
        mountComponent({ data: { alert: null } });
      });

      it('shows an empty state', () => {
        expect(wrapper.find('[data-testid="alertDetailsTabs"]').exists()).toBe(false);
      });
    });

    describe('when alert is present', () => {
      beforeEach(() => {
        mountComponent({ data: { alert: mockAlert } });
      });

      it('renders a tab with overview information', () => {
        expect(wrapper.find('[data-testid="overviewTab"]').exists()).toBe(true);
      });

      it('renders a tab with full alert information', () => {
        expect(wrapper.find('[data-testid="fullDetailsTab"]').exists()).toBe(true);
      });

      it('renders a title', () => {
        expect(wrapper.find('[data-testid="title"]').text()).toBe(mockAlert.title);
      });

      it('renders a start time', () => {
        expect(wrapper.find('[data-testid="startTimeItem"]').exists()).toBe(true);
        expect(wrapper.find('[data-testid="startTimeItem"]').props().time).toBe(
          mockAlert.startedAt,
        );
      });
    });

    describe('individual alert fields', () => {
      describe.each`
        field               | data            | isShown
        ${'eventCount'}     | ${1}            | ${true}
        ${'eventCount'}     | ${undefined}    | ${false}
        ${'monitoringTool'} | ${'New Relic'}  | ${true}
        ${'monitoringTool'} | ${undefined}    | ${false}
        ${'service'}        | ${'Prometheus'} | ${true}
        ${'service'}        | ${undefined}    | ${false}
      `(`$desc`, ({ field, data, isShown }) => {
        beforeEach(() => {
          mountComponent({ data: { alert: { ...mockAlert, [field]: data } } });
        });

        it(`${field} is ${isShown ? 'displayed' : 'hidden'} correctly`, () => {
          if (isShown) {
            expect(wrapper.find(`[data-testid="${field}"]`).text()).toBe(data.toString());
          } else {
            expect(wrapper.find(`[data-testid="${field}"]`).exists()).toBe(false);
          }
        });
      });
    });

    it('renders a status dropdown containing three items', () => {
      expect(wrapper.findAll('[data-testid="statusDropdownItem"]').length).toBe(3);
    });

    describe('Create issue from alert', () => {
      describe('createIssueFromAlertEnabled feature flag enabled', () => {
        it('should display a button that links to new issue page', () => {
          mountComponent({ createIssueFromAlertEnabled: true });
          expect(findCreatedIssueBtn().exists()).toBe(true);
          expect(findCreatedIssueBtn().attributes('href')).toBe(newIssuePath);
        });
      });

      describe('createIssueFromAlertEnabled feature flag disabled', () => {
        it('should display a button that links to a new issue page', () => {
          mountComponent({ createIssueFromAlertEnabled: false });
          expect(findCreatedIssueBtn().exists()).toBe(false);
        });
      });
    });

    describe('loading state', () => {
      beforeEach(() => {
        mountComponent({ loading: true });
      });

      it('displays a loading state when loading', () => {
        expect(wrapper.find(GlLoadingIcon).exists()).toBe(true);
      });
    });

    describe('error state', () => {
      it('displays a error state correctly', () => {
        mountComponent({ data: { errored: true } });
        expect(wrapper.find(GlAlert).exists()).toBe(true);
      });

      it('does not display an error when dismissed', () => {
        mountComponent({ data: { errored: true, isErrorDismissed: true } });
        expect(wrapper.find(GlAlert).exists()).toBe(false);
      });
    });

    describe('alert status dropdown', () => {
      it('displays the current status', () => {
        mountComponent({ data: { alert: { status: 'ACKNOWLEDGED' } } });
        expect(findStatusDropdown().attributes().text).toBe('Acknowledged');
      });
    });

    describe('updating the alert status', () => {
      const iid = '1527542';
      const mockUpdatedMutationResult = {
        data: {
          updateAlertStatus: {
            alert: {
              iid,
              status: 'ACKNOWLEDGED',
            },
          },
        },
      };

      beforeEach(() => {
        mountComponent({ data: { alert: mockAlert } });
      });

      it('calls `$apollo.mutate` with `updateAlertStatus` mutation and variables containing `iid`, `status`, & `projectPath`', () => {
        jest.spyOn(wrapper.vm.$apollo, 'mutate').mockResolvedValue(mockUpdatedMutationResult);
        findFirstStatusOption().vm.$emit('click');

        expect(wrapper.vm.$apollo.mutate).toHaveBeenCalledWith({
          mutation: updateAlertStatus,
          variables: {
            iid,
            status: 'TRIGGERED',
            projectPath: 'gitlab-org/gitlab',
          },
        });
      });

      it('calls `createFlash` when request fails', () => {
        jest.spyOn(wrapper.vm.$apollo, 'mutate').mockReturnValue(Promise.reject(new Error()));
        findFirstStatusOption().vm.$emit('click');

        setImmediate(() => {
          expect(createFlash).toHaveBeenCalledWith(
            'There was an error while updating the status of the alert. Please try again.',
          );
        });
      });
    });
  });
});
