import { mount } from '@vue/test-utils';
import {
  GlTable,
  GlAlert,
  GlLoadingIcon,
  GlDeprecatedDropdown,
  GlDeprecatedDropdownItem,
  GlIcon,
  GlTabs,
  GlTab,
  GlBadge,
  GlPagination,
  GlSearchBoxByType,
  GlAvatar,
} from '@gitlab/ui';
import waitForPromises from 'helpers/wait_for_promises';
import { visitUrl } from '~/lib/utils/url_utility';
import TimeAgo from '~/vue_shared/components/time_ago_tooltip.vue';
import AlertManagementTable from '~/alert_management/components/alert_management_table.vue';
import { ALERTS_STATUS_TABS, trackAlertStatusUpdateOptions } from '~/alert_management/constants';
import updateAlertStatus from '~/alert_management/graphql/mutations/update_alert_status.mutation.graphql';
import mockAlerts from '../mocks/alerts.json';
import Tracking from '~/tracking';

jest.mock('~/lib/utils/url_utility', () => ({
  visitUrl: jest.fn().mockName('visitUrlMock'),
  joinPaths: jest.requireActual('~/lib/utils/url_utility').joinPaths,
}));

describe('AlertManagementTable', () => {
  let wrapper;

  const findAlertsTable = () => wrapper.find(GlTable);
  const findAlerts = () => wrapper.findAll('table tbody tr');
  const findAlert = () => wrapper.find(GlAlert);
  const findLoader = () => wrapper.find(GlLoadingIcon);
  const findStatusDropdown = () => wrapper.find(GlDeprecatedDropdown);
  const findStatusFilterTabs = () => wrapper.findAll(GlTab);
  const findStatusTabs = () => wrapper.find(GlTabs);
  const findStatusFilterBadge = () => wrapper.findAll(GlBadge);
  const findDateFields = () => wrapper.findAll(TimeAgo);
  const findFirstStatusOption = () => findStatusDropdown().find(GlDeprecatedDropdownItem);
  const findPagination = () => wrapper.find(GlPagination);
  const findSearch = () => wrapper.find(GlSearchBoxByType);
  const findSeverityColumnHeader = () =>
    wrapper.find('[data-testid="alert-management-severity-sort"]');
  const findFirstIDField = () => wrapper.findAll('[data-testid="idField"]').at(0);
  const findAssignees = () => wrapper.findAll('[data-testid="assigneesField"]');
  const findSeverityFields = () => wrapper.findAll('[data-testid="severityField"]');
  const findIssueFields = () => wrapper.findAll('[data-testid="issueField"]');
  const findAlertError = () => wrapper.find('[data-testid="alert-error"]');
  const alertsCount = {
    open: 24,
    triggered: 20,
    acknowledged: 16,
    resolved: 11,
    all: 26,
  };
  const selectFirstStatusOption = () => {
    findFirstStatusOption().vm.$emit('click');

    return waitForPromises();
  };

  function mountComponent({
    props = {
      alertManagementEnabled: false,
      userCanEnableAlertManagement: false,
    },
    data = {},
    loading = false,
    stubs = {},
  } = {}) {
    wrapper = mount(AlertManagementTable, {
      propsData: {
        projectPath: 'gitlab-org/gitlab',
        populatingAlertsHelpUrl: '/help/help-page.md#populating-alert-data',
        ...props,
      },
      data() {
        return data;
      },
      mocks: {
        $apollo: {
          mutate: jest.fn(),
          query: jest.fn(),
          queries: {
            alerts: {
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
      wrapper = null;
    }
  });

  describe('Status Filter Tabs', () => {
    beforeEach(() => {
      mountComponent({
        props: { alertManagementEnabled: true, userCanEnableAlertManagement: true },
        data: { alerts: mockAlerts, alertsCount },
        loading: false,
        stubs: {
          GlTab: true,
        },
      });
    });

    it('should display filter tabs with alerts count badge for each status', () => {
      const tabs = findStatusFilterTabs().wrappers;
      const badges = findStatusFilterBadge();

      tabs.forEach((tab, i) => {
        const status = ALERTS_STATUS_TABS[i].status.toLowerCase();
        expect(tab.text()).toContain(ALERTS_STATUS_TABS[i].title);
        expect(badges.at(i).text()).toContain(alertsCount[status]);
      });
    });
  });

  describe('Alerts table', () => {
    it('loading state', () => {
      mountComponent({
        props: { alertManagementEnabled: true, userCanEnableAlertManagement: true },
        data: { alerts: {}, alertsCount: null },
        loading: true,
      });
      expect(findAlertsTable().exists()).toBe(true);
      expect(findLoader().exists()).toBe(true);
      expect(
        findAlerts()
          .at(0)
          .classes(),
      ).not.toContain('gl-hover-bg-blue-50');
    });

    it('error state', () => {
      mountComponent({
        props: { alertManagementEnabled: true, userCanEnableAlertManagement: true },
        data: { alerts: { errors: ['error'] }, alertsCount: null, hasError: true },
        loading: false,
      });
      expect(findAlertsTable().exists()).toBe(true);
      expect(findAlertsTable().text()).toContain('No alerts to display');
      expect(findLoader().exists()).toBe(false);
      expect(findAlert().props().variant).toBe('danger');
      expect(
        findAlerts()
          .at(0)
          .classes(),
      ).not.toContain('gl-hover-bg-blue-50');
    });

    it('empty state', () => {
      mountComponent({
        props: { alertManagementEnabled: true, userCanEnableAlertManagement: true },
        data: { alerts: { list: [], pageInfo: {} }, alertsCount: { all: 0 }, hasError: false },
        loading: false,
      });
      expect(findAlertsTable().exists()).toBe(true);
      expect(findAlertsTable().text()).toContain('No alerts to display');
      expect(findLoader().exists()).toBe(false);
      expect(findAlert().props().variant).toBe('info');
      expect(
        findAlerts()
          .at(0)
          .classes(),
      ).not.toContain('gl-hover-bg-blue-50');
    });

    it('has data state', () => {
      mountComponent({
        props: { alertManagementEnabled: true, userCanEnableAlertManagement: true },
        data: { alerts: { list: mockAlerts }, alertsCount, hasError: false },
        loading: false,
      });
      expect(findLoader().exists()).toBe(false);
      expect(findAlertsTable().exists()).toBe(true);
      expect(findAlerts()).toHaveLength(mockAlerts.length);
      expect(
        findAlerts()
          .at(0)
          .classes(),
      ).toContain('gl-hover-bg-blue-50');
    });

    it('displays the alert ID and title formatted correctly', () => {
      mountComponent({
        props: { alertManagementEnabled: true, userCanEnableAlertManagement: true },
        data: { alerts: { list: mockAlerts }, alertsCount, hasError: false },
        loading: false,
      });

      expect(findFirstIDField().exists()).toBe(true);
      expect(findFirstIDField().text()).toBe(`#${mockAlerts[0].iid} ${mockAlerts[0].title}`);
    });

    it('displays status dropdown', () => {
      mountComponent({
        props: { alertManagementEnabled: true, userCanEnableAlertManagement: true },
        data: { alerts: { list: mockAlerts }, alertsCount, hasError: false },
        loading: false,
      });
      expect(findStatusDropdown().exists()).toBe(true);
    });

    it('does not display a dropdown status header', () => {
      mountComponent({
        props: { alertManagementEnabled: true, userCanEnableAlertManagement: true },
        data: { alerts: { list: mockAlerts }, alertsCount, hasError: false },
        loading: false,
      });
      expect(
        findStatusDropdown()
          .find('.dropdown-title')
          .exists(),
      ).toBe(false);
    });

    it('shows correct severity icons', () => {
      mountComponent({
        props: { alertManagementEnabled: true, userCanEnableAlertManagement: true },
        data: { alerts: { list: mockAlerts }, alertsCount, hasError: false },
        loading: false,
      });

      return wrapper.vm.$nextTick().then(() => {
        expect(wrapper.find(GlTable).exists()).toBe(true);
        expect(
          findAlertsTable()
            .find(GlIcon)
            .classes('icon-critical'),
        ).toBe(true);
      });
    });

    it('renders severity text', () => {
      mountComponent({
        props: { alertManagementEnabled: true, userCanEnableAlertManagement: true },
        data: { alerts: { list: mockAlerts }, alertsCount, hasError: false },
        loading: false,
      });

      expect(
        findSeverityFields()
          .at(0)
          .text(),
      ).toBe('Critical');
    });

    it('renders Unassigned when no assignee(s) present', () => {
      mountComponent({
        props: { alertManagementEnabled: true, userCanEnableAlertManagement: true },
        data: { alerts: { list: mockAlerts }, alertsCount, hasError: false },
        loading: false,
      });

      expect(
        findAssignees()
          .at(0)
          .text(),
      ).toBe('Unassigned');
    });

    it('renders user avatar when assignee present', () => {
      mountComponent({
        props: { alertManagementEnabled: true, userCanEnableAlertManagement: true },
        data: { alerts: { list: mockAlerts }, alertsCount, hasError: false },
        loading: false,
      });

      const avatar = findAssignees()
        .at(1)
        .find(GlAvatar);
      const { src, label } = avatar.attributes();
      const { name, avatarUrl } = mockAlerts[1].assignees.nodes[0];

      expect(avatar.exists()).toBe(true);
      expect(label).toBe(name);
      expect(src).toBe(avatarUrl);
    });

    it('navigates to the detail page when alert row is clicked', () => {
      mountComponent({
        props: { alertManagementEnabled: true, userCanEnableAlertManagement: true },
        data: { alerts: { list: mockAlerts }, alertsCount, hasError: false },
        loading: false,
      });

      expect(visitUrl).not.toHaveBeenCalled();

      findAlerts()
        .at(0)
        .trigger('click');
      expect(visitUrl).toHaveBeenCalledWith('/1527542/details', false);
    });

    it('navigates to the detail page in new tab when alert row is clicked with the metaKey', () => {
      mountComponent({
        props: { alertManagementEnabled: true, userCanEnableAlertManagement: true },
        data: { alerts: { list: mockAlerts }, alertsCount, hasError: false },
        loading: false,
      });

      expect(visitUrl).not.toHaveBeenCalled();

      findAlerts()
        .at(0)
        .trigger('click', {
          metaKey: true,
        });

      expect(visitUrl).toHaveBeenCalledWith('/1527542/details', true);
    });

    describe('alert issue links', () => {
      beforeEach(() => {
        mountComponent({
          props: { alertManagementEnabled: true, userCanEnableAlertManagement: true },
          data: { alerts: { list: mockAlerts }, alertsCount, hasError: false },
          loading: false,
        });
      });

      it('shows "None" when no link exists', () => {
        expect(
          findIssueFields()
            .at(0)
            .text(),
        ).toBe('None');
      });

      it('renders a link when one exists', () => {
        expect(
          findIssueFields()
            .at(1)
            .text(),
        ).toBe('#1');
        expect(
          findIssueFields()
            .at(1)
            .attributes('href'),
        ).toBe('/gitlab-org/gitlab/-/issues/1');
      });
    });

    describe('handle date fields', () => {
      it('should display time ago dates when values provided', () => {
        mountComponent({
          props: { alertManagementEnabled: true, userCanEnableAlertManagement: true },
          data: {
            alerts: {
              list: [
                {
                  iid: 1,
                  status: 'acknowledged',
                  startedAt: '2020-03-17T23:18:14.996Z',
                  severity: 'high',
                  assignees: { nodes: [] },
                },
              ],
            },
            alertsCount,
            hasError: false,
          },
          loading: false,
        });
        expect(findDateFields().length).toBe(1);
      });

      it('should not display time ago dates when values not provided', () => {
        mountComponent({
          props: { alertManagementEnabled: true, userCanEnableAlertManagement: true },
          data: {
            alerts: [
              {
                iid: 1,
                status: 'acknowledged',
                startedAt: null,
                severity: 'high',
              },
            ],
            alertsCount,
            hasError: false,
          },
          loading: false,
        });
        expect(findDateFields().exists()).toBe(false);
      });

      describe('New Alert indicator', () => {
        const oldAlert = mockAlerts[0];

        const newAlert = { ...oldAlert, isNew: true };

        it('should highlight the row when alert is new', () => {
          mountComponent({
            props: { alertManagementEnabled: true, userCanEnableAlertManagement: true },
            data: { alerts: { list: [newAlert] }, alertsCount, hasError: false },
            loading: false,
          });

          expect(
            findAlerts()
              .at(0)
              .classes(),
          ).toContain('new-alert');
        });

        it('should not highlight the row when alert is not new', () => {
          mountComponent({
            props: { alertManagementEnabled: true, userCanEnableAlertManagement: true },
            data: { alerts: { list: [oldAlert] }, alertsCount, hasError: false },
            loading: false,
          });

          expect(
            findAlerts()
              .at(0)
              .classes(),
          ).not.toContain('new-alert');
        });
      });
    });
  });

  describe('sorting the alert list by column', () => {
    beforeEach(() => {
      mountComponent({
        props: { alertManagementEnabled: true, userCanEnableAlertManagement: true },
        data: {
          alerts: { list: mockAlerts },
          hasError: false,
          sort: 'STARTED_AT_DESC',
          alertsCount,
        },
        loading: false,
        stubs: { GlTable },
      });
    });

    it('updates sort with new direction and column key', () => {
      findSeverityColumnHeader().trigger('click');

      expect(wrapper.vm.$data.sort).toBe('SEVERITY_DESC');

      findSeverityColumnHeader().trigger('click');

      expect(wrapper.vm.$data.sort).toBe('SEVERITY_ASC');
    });
  });

  describe('updating the alert status', () => {
    const iid = '1527542';
    const mockUpdatedMutationResult = {
      data: {
        updateAlertStatus: {
          errors: [],
          alert: {
            iid,
            status: 'acknowledged',
          },
        },
      },
    };

    beforeEach(() => {
      mountComponent({
        props: { alertManagementEnabled: true, userCanEnableAlertManagement: true },
        data: { alerts: { list: mockAlerts }, alertsCount, hasError: false },
        loading: false,
      });
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

    describe('when a request fails', () => {
      beforeEach(() => {
        jest.spyOn(wrapper.vm.$apollo, 'mutate').mockReturnValue(Promise.reject(new Error()));
      });

      it('shows an error', async () => {
        await selectFirstStatusOption();

        expect(findAlertError().text()).toContain(
          'There was an error while updating the status of the alert.',
        );
      });

      it('shows an error when triggered a second time', async () => {
        await selectFirstStatusOption();

        wrapper.find(GlAlert).vm.$emit('dismiss');

        await wrapper.vm.$nextTick();

        // Assert that the error has been dismissed in the setup
        expect(findAlertError().exists()).toBe(false);

        await selectFirstStatusOption();

        expect(findAlertError().exists()).toBe(true);
      });
    });

    it('shows an error when response includes HTML errors', async () => {
      const mockUpdatedMutationErrorResult = {
        data: {
          updateAlertStatus: {
            errors: ['<span data-testid="htmlError" />'],
            alert: {
              iid,
              status: 'acknowledged',
            },
          },
        },
      };

      jest.spyOn(wrapper.vm.$apollo, 'mutate').mockResolvedValue(mockUpdatedMutationErrorResult);

      await selectFirstStatusOption();

      expect(findAlertError().exists()).toBe(true);
      expect(
        findAlertError()
          .find('[data-testid="htmlError"]')
          .exists(),
      ).toBe(true);
    });
  });

  describe('Snowplow tracking', () => {
    beforeEach(() => {
      jest.spyOn(Tracking, 'event');
      mountComponent({
        props: { alertManagementEnabled: true, userCanEnableAlertManagement: true },
        data: { alerts: { list: mockAlerts }, alertsCount },
        loading: false,
      });
    });

    it('should track alert status updates', () => {
      Tracking.event.mockClear();
      jest.spyOn(wrapper.vm.$apollo, 'mutate').mockResolvedValue({});
      findFirstStatusOption().vm.$emit('click');
      const status = findFirstStatusOption().text();
      setImmediate(() => {
        const { category, action, label } = trackAlertStatusUpdateOptions;
        expect(Tracking.event).toHaveBeenCalledWith(category, action, { label, property: status });
      });
    });
  });

  describe('Pagination', () => {
    beforeEach(() => {
      mountComponent({
        props: { alertManagementEnabled: true, userCanEnableAlertManagement: true },
        data: { alerts: { list: mockAlerts, pageInfo: {} }, alertsCount, hasError: false },
        loading: false,
      });
    });

    it('does NOT show pagination control when list is smaller than default page size', () => {
      findStatusTabs().vm.$emit('input', 3);
      return wrapper.vm.$nextTick(() => {
        expect(findPagination().exists()).toBe(false);
      });
    });

    it('shows pagination control when list is larger than default page size', () => {
      findStatusTabs().vm.$emit('input', 0);
      return wrapper.vm.$nextTick(() => {
        expect(findPagination().exists()).toBe(true);
      });
    });

    describe('prevPage', () => {
      it('returns prevPage number', () => {
        findPagination().vm.$emit('input', 3);

        return wrapper.vm.$nextTick(() => {
          expect(wrapper.vm.prevPage).toBe(2);
        });
      });

      it('returns 0 when it is the first page', () => {
        findPagination().vm.$emit('input', 1);

        return wrapper.vm.$nextTick(() => {
          expect(wrapper.vm.prevPage).toBe(0);
        });
      });
    });

    describe('nextPage', () => {
      it('returns nextPage number', () => {
        findPagination().vm.$emit('input', 1);

        return wrapper.vm.$nextTick(() => {
          expect(wrapper.vm.nextPage).toBe(2);
        });
      });

      it('returns `null` when currentPage is already last page', () => {
        findStatusTabs().vm.$emit('input', 3);
        findPagination().vm.$emit('input', 1);
        return wrapper.vm.$nextTick(() => {
          expect(wrapper.vm.nextPage).toBeNull();
        });
      });
    });
  });

  describe('Search', () => {
    beforeEach(() => {
      mountComponent({
        props: { alertManagementEnabled: true, userCanEnableAlertManagement: true },
        data: { alerts: { list: mockAlerts }, alertsCount, hasError: false },
        loading: false,
      });
    });

    it('renders the search component', () => {
      expect(findSearch().exists()).toBe(true);
    });

    it('sets the `searchTerm` graphql variable', () => {
      const SEARCH_TERM = 'Simple Alert';

      findSearch().vm.$emit('input', SEARCH_TERM);

      expect(wrapper.vm.$data.searchTerm).toBe(SEARCH_TERM);
    });
  });
});
