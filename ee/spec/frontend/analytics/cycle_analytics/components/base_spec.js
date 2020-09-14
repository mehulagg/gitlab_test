import { createLocalVue, shallowMount, mount } from '@vue/test-utils';
import Vuex from 'vuex';
import store from 'ee/analytics/cycle_analytics/store';
import Component from 'ee/analytics/cycle_analytics/components/base.vue';
import { GlEmptyState } from '@gitlab/ui';
import axios from 'axios';
import MockAdapter from 'axios-mock-adapter';
import GroupsDropdownFilter from 'ee/analytics/shared/components/groups_dropdown_filter.vue';
import ProjectsDropdownFilter from 'ee/analytics/shared/components/projects_dropdown_filter.vue';
import Metrics from 'ee/analytics/cycle_analytics/components/metrics.vue';
import PathNavigation from 'ee/analytics/cycle_analytics/components/path_navigation.vue';
import StageTable from 'ee/analytics/cycle_analytics/components/stage_table.vue';
import StageTableNav from 'ee/analytics/cycle_analytics/components/stage_table_nav.vue';
import StageNavItem from 'ee/analytics/cycle_analytics/components/stage_nav_item.vue';
import AddStageButton from 'ee/analytics/cycle_analytics/components/add_stage_button.vue';
import CustomStageForm from 'ee/analytics/cycle_analytics/components/custom_stage_form.vue';
import FilterBar from 'ee/analytics/cycle_analytics/components/filter_bar.vue';
import DurationChart from 'ee/analytics/cycle_analytics/components/duration_chart.vue';
import Daterange from 'ee/analytics/shared/components/daterange.vue';
import TypeOfWorkCharts from 'ee/analytics/cycle_analytics/components/type_of_work_charts.vue';
import ValueStreamSelect from 'ee/analytics/cycle_analytics/components/value_stream_select.vue';
import waitForPromises from 'helpers/wait_for_promises';
import { toYmd } from 'ee/analytics/shared/utils';
import httpStatusCodes from '~/lib/utils/http_status';
import UrlSync from '~/vue_shared/components/url_sync.vue';
import * as commonUtils from '~/lib/utils/common_utils';
import * as urlUtils from '~/lib/utils/url_utility';
import * as mockData from '../mock_data';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';

const noDataSvgPath = 'path/to/no/data';
const noAccessSvgPath = 'path/to/no/access';
const emptyStateSvgPath = 'path/to/empty/state';
const hideGroupDropDown = false;
const selectedGroup = convertObjectPropsToCamelCase(mockData.group);

const localVue = createLocalVue();
localVue.use(Vuex);

const defaultStubs = {
  'stage-event-list': true,
  'stage-nav-item': true,
  'tasks-by-type-chart': true,
  'labels-selector': true,
  DurationChart: true,
  GroupsDropdownFilter: true,
  ValueStreamSelect: true,
  Metrics: true,
  UrlSync,
};

const defaultFeatureFlags = {
  hasDurationChart: true,
  hasPathNavigation: false,
  hasCreateMultipleValueStreams: false,
};

const initialCycleAnalyticsState = {
  createdAfter: mockData.startDate,
  createdBefore: mockData.endDate,
  group: selectedGroup,
};

const mocks = {
  $toast: {
    show: jest.fn(),
  },
};

function createComponent({
  opts = {
    stubs: defaultStubs,
  },
  shallow = true,
  withStageSelected = false,
  withValueStreamSelected = true,
  featureFlags = {},
  props = {},
} = {}) {
  const func = shallow ? shallowMount : mount;
  const comp = func(Component, {
    localVue,
    store,
    propsData: {
      emptyStateSvgPath,
      noDataSvgPath,
      noAccessSvgPath,
      hideGroupDropDown,
      ...props,
    },
    mocks,
    ...opts,
  });

  comp.vm.$store.dispatch('initializeCycleAnalytics', {
    createdAfter: mockData.startDate,
    createdBefore: mockData.endDate,
    featureFlags: {
      ...defaultFeatureFlags,
      ...featureFlags,
    },
  });

  if (withValueStreamSelected) {
    comp.vm.$store.dispatch('receiveValueStreamsSuccess', mockData.valueStreams);
  }

  if (withStageSelected) {
    comp.vm.$store.commit('SET_SELECTED_GROUP', {
      ...selectedGroup,
    });

    comp.vm.$store.dispatch(
      'receiveGroupStagesSuccess',
      mockData.customizableStagesAndEvents.stages,
    );

    comp.vm.$store.dispatch('receiveStageDataSuccess', mockData.issueEvents);
  }
  return comp;
}

async function shouldMergeUrlParams(wrapper, result) {
  await wrapper.vm.$nextTick();
  expect(urlUtils.mergeUrlParams).toHaveBeenCalledWith(result, window.location.href, {
    spreadArrays: true,
  });
  expect(commonUtils.historyPushState).toHaveBeenCalled();
}

describe('Cycle Analytics component', () => {
  let wrapper;
  let mock;

  const findStageNavItemAtIndex = index =>
    wrapper
      .find(StageTableNav)
      .findAll(StageNavItem)
      .at(index);

  const findAddStageButton = () => wrapper.find(AddStageButton);

  const displaysProjectsDropdownFilter = flag => {
    expect(wrapper.find(ProjectsDropdownFilter).exists()).toBe(flag);
  };

  const displaysDateRangePicker = flag => {
    expect(wrapper.find(Daterange).exists()).toBe(flag);
  };

  const displaysMetrics = flag => {
    expect(wrapper.find(Metrics).exists()).toBe(flag);
  };

  const displaysStageTable = flag => {
    expect(wrapper.find(StageTable).exists()).toBe(flag);
  };

  const displaysDurationChart = flag => {
    expect(wrapper.find(DurationChart).exists()).toBe(flag);
  };

  const displaysTypeOfWork = flag => {
    expect(wrapper.find(TypeOfWorkCharts).exists()).toBe(flag);
  };

  const displaysPathNavigation = flag => {
    expect(wrapper.find(PathNavigation).exists()).toBe(flag);
  };

  const displaysAddStageButton = flag => {
    expect(wrapper.find(AddStageButton).exists()).toBe(flag);
  };

  const displaysFilterBar = flag => {
    expect(wrapper.find(FilterBar).exists()).toBe(flag);
  };

  const displaysValueStreamSelect = flag => {
    expect(wrapper.find(ValueStreamSelect).exists()).toBe(flag);
  };

  beforeEach(() => {
    mock = new MockAdapter(axios);
    wrapper = createComponent({
      featureFlags: {
        hasPathNavigation: true,
      },
    });
  });

  afterEach(() => {
    wrapper.destroy();
    mock.restore();
    wrapper = null;
  });

  describe('displays the components as required', () => {
    describe('before a filter has been selected', () => {
      it('displays an empty state', () => {
        const emptyState = wrapper.find(GlEmptyState);

        expect(emptyState.exists()).toBe(true);
        expect(emptyState.props('svgPath')).toBe(emptyStateSvgPath);
      });

      it('displays the groups filter', () => {
        expect(wrapper.find(GroupsDropdownFilter).exists()).toBe(true);
        expect(wrapper.find(GroupsDropdownFilter).props('queryParams')).toEqual(
          wrapper.vm.$options.groupsQueryParams,
        );
      });

      it('does not display the projects filter', () => {
        displaysProjectsDropdownFilter(false);
      });

      it('does not display the date range picker', () => {
        displaysDateRangePicker(false);
      });

      it('does not display the metrics cards', () => {
        displaysMetrics(false);
      });

      it('does not display the stage table', () => {
        displaysStageTable(false);
      });

      it('does not display the duration chart', () => {
        displaysDurationChart(false);
      });

      it('does not display the add stage button', () => {
        displaysAddStageButton(false);
      });

      it('does not display the path navigation', () => {
        displaysPathNavigation(false);
      });

      it('does not display the value stream select component', () => {
        displaysValueStreamSelect(false);
      });

      describe('hideGroupDropDown = true', () => {
        beforeEach(() => {
          mock = new MockAdapter(axios);
          wrapper = createComponent({
            props: {
              hideGroupDropDown: true,
            },
          });
        });

        it('does not render the group dropdown', () => {
          expect(wrapper.find(GroupsDropdownFilter).exists()).toBe(false);
        });
      });

      describe('hasCreateMultipleValueStreams = true', () => {
        beforeEach(() => {
          mock = new MockAdapter(axios);
          wrapper = createComponent({
            featureFlags: {
              hasCreateMultipleValueStreams: true,
            },
          });
        });

        it('displays the value stream select component', () => {
          displaysValueStreamSelect(true);
        });
      });
    });

    describe('after a filter has been selected', () => {
      describe('the user has access to the group', () => {
        beforeEach(() => {
          mock = new MockAdapter(axios);
          wrapper = createComponent({
            withStageSelected: true,
            featureFlags: {
              hasPathNavigation: true,
            },
          });
        });

        it('hides the empty state', () => {
          expect(wrapper.find(GlEmptyState).exists()).toBe(false);
        });

        it('displays the projects filter', () => {
          displaysProjectsDropdownFilter(true);

          expect(wrapper.find(ProjectsDropdownFilter).props()).toEqual(
            expect.objectContaining({
              queryParams: wrapper.vm.projectsQueryParams,
              groupId: mockData.group.id,
              multiSelect: wrapper.vm.$options.multiProjectSelect,
            }),
          );
        });

        describe('when analyticsSimilaritySearch feature flag is on', () => {
          beforeEach(() => {
            wrapper = createComponent({
              withStageSelected: true,
              featureFlags: {
                hasAnalyticsSimilaritySearch: true,
              },
            });
          });

          it('uses similarity as the order param', () => {
            displaysProjectsDropdownFilter(true);

            expect(wrapper.find(ProjectsDropdownFilter).props().queryParams.order_by).toEqual(
              'similarity',
            );
          });
        });

        it('displays the date range picker', () => {
          displaysDateRangePicker(true);
        });

        it('displays the metrics', () => {
          displaysMetrics(true);
        });

        it('displays the stage table', () => {
          displaysStageTable(true);
        });

        it('displays the filter bar', () => {
          displaysFilterBar(true);
        });

        it('displays the add stage button', () => {
          wrapper = createComponent({
            opts: {
              stubs: {
                StageTable,
                StageTableNav,
              },
            },
            withStageSelected: true,
          });

          return wrapper.vm.$nextTick().then(() => {
            displaysAddStageButton(true);
          });
        });

        it('displays the tasks by type chart', () => {
          wrapper = createComponent({ shallow: false, withStageSelected: true });
          return wrapper.vm.$nextTick().then(() => {
            expect(wrapper.find('.js-tasks-by-type-chart').exists()).toBe(true);
          });
        });

        it('displays the duration chart', () => {
          displaysDurationChart(true);
        });

        describe('path navigation', () => {
          describe('disabled', () => {
            beforeEach(() => {
              wrapper = createComponent({
                withStageSelected: true,
                featureFlags: {
                  hasPathNavigation: false,
                },
              });
            });

            it('does not display the path navigation', () => {
              displaysPathNavigation(false);
            });
          });

          describe('enabled', () => {
            beforeEach(() => {
              wrapper = createComponent({
                withStageSelected: true,
                featureFlags: {
                  hasPathNavigation: true,
                },
              });
            });

            it('displays the path navigation', () => {
              displaysPathNavigation(true);
            });
          });
        });

        describe('StageTable', () => {
          beforeEach(() => {
            mock = new MockAdapter(axios);

            wrapper = createComponent({
              opts: {
                stubs: {
                  StageTable,
                  StageTableNav,
                  StageNavItem,
                },
              },
              withValueStreamSelected: false,
              withStageSelected: true,
            });
          });

          it('has the first stage selected by default', () => {
            const first = findStageNavItemAtIndex(0);
            const second = findStageNavItemAtIndex(1);

            expect(first.props('isActive')).toBe(true);
            expect(second.props('isActive')).toBe(false);
          });

          it('can navigate to different stages', () => {
            findStageNavItemAtIndex(2).trigger('click');

            return wrapper.vm.$nextTick().then(() => {
              const first = findStageNavItemAtIndex(0);
              const third = findStageNavItemAtIndex(2);

              expect(third.props('isActive')).toBe(true);
              expect(first.props('isActive')).toBe(false);
            });
          });

          describe('Add stage button', () => {
            beforeEach(() => {
              wrapper = createComponent({
                opts: {
                  stubs: {
                    StageTable,
                    StageTableNav,
                    AddStageButton,
                  },
                },
                withStageSelected: true,
              });
            });

            it('can navigate to the custom stage form', () => {
              expect(wrapper.find(CustomStageForm).exists()).toBe(false);

              findAddStageButton().trigger('click');

              return wrapper.vm.$nextTick().then(() => {
                expect(wrapper.find(CustomStageForm).exists()).toBe(true);
              });
            });
          });
        });
      });

      describe('the user does not have access to the group', () => {
        beforeEach(() => {
          mock = new MockAdapter(axios);
          mock.onAny().reply(httpStatusCodes.FORBIDDEN);

          wrapper.vm.onGroupSelect(mockData.group);
          return waitForPromises();
        });

        it('renders the no access information', () => {
          const emptyState = wrapper.find(GlEmptyState);

          expect(emptyState.exists()).toBe(true);
          expect(emptyState.props('svgPath')).toBe(noAccessSvgPath);
        });

        it('does not display the projects filter', () => {
          displaysProjectsDropdownFilter(false);
        });

        it('does not display the date range picker', () => {
          displaysDateRangePicker(false);
        });

        it('does not display the metrics', () => {
          displaysMetrics(false);
        });

        it('does not display the stage table', () => {
          displaysStageTable(false);
        });

        it('does not display the add stage button', () => {
          displaysAddStageButton(false);
        });

        it('does not display the tasks by type chart', () => {
          displaysTypeOfWork(false);
        });

        it('does not display the duration chart', () => {
          displaysDurationChart(false);
        });

        describe('path navigation', () => {
          describe('disabled', () => {
            it('does not display the path navigation', () => {
              displaysPathNavigation(false);
            });
          });

          describe('enabled', () => {
            beforeEach(() => {
              wrapper = createComponent({
                withValueStreamSelected: false,
                withStageSelected: true,
                pathNavigationEnabled: true,
              });

              mock = new MockAdapter(axios);
              mock.onAny().reply(httpStatusCodes.FORBIDDEN);

              wrapper.vm.onGroupSelect(mockData.group);
              return waitForPromises();
            });

            it('does not display the path navigation', () => {
              displaysPathNavigation(false);
            });
          });
        });
      });
    });
  });

  describe('with failed requests while loading', () => {
    const mockRequestCycleAnalyticsData = ({
      overrides = {},
      mockFetchStageData = true,
      mockFetchStageMedian = true,
      mockFetchTasksByTypeData = true,
      mockFetchTopRankedGroupLabels = true,
    }) => {
      const defaultStatus = 200;
      const defaultRequests = {
        fetchGroupStagesAndEvents: {
          status: defaultStatus,
          endpoint: mockData.endpoints.baseStagesEndpoint,
          response: { ...mockData.customizableStagesAndEvents },
        },
        ...overrides,
      };

      if (mockFetchTopRankedGroupLabels) {
        mock
          .onGet(mockData.endpoints.tasksByTypeTopLabelsData)
          .reply(defaultStatus, mockData.groupLabels);
      }

      if (mockFetchTasksByTypeData) {
        mock
          .onGet(mockData.endpoints.tasksByTypeData)
          .reply(defaultStatus, { ...mockData.tasksByTypeData });
      }

      if (mockFetchStageMedian) {
        mock.onGet(mockData.endpoints.stageMedian).reply(defaultStatus, { value: null });
      }

      if (mockFetchStageData) {
        mock.onGet(mockData.endpoints.stageData).reply(defaultStatus, mockData.issueEvents);
      }

      Object.values(defaultRequests).forEach(({ endpoint, status, response }) => {
        mock.onGet(endpoint).replyOnce(status, response);
      });
    };

    beforeEach(() => {
      setFixtures('<div class="flash-container"></div>');

      mock = new MockAdapter(axios);
      wrapper = createComponent();
    });

    afterEach(() => {
      wrapper.destroy();
      mock.restore();
    });

    const findFlashError = () => document.querySelector('.flash-container .flash-text');
    const selectGroupAndFindError = msg => {
      wrapper.vm.onGroupSelect(mockData.group);

      return waitForPromises().then(() => {
        expect(findFlashError().innerText.trim()).toEqual(msg);
      });
    };

    it('will display an error if the fetchGroupStagesAndEvents request fails', () => {
      expect(findFlashError()).toBeNull();

      mockRequestCycleAnalyticsData({
        overrides: {
          fetchGroupStagesAndEvents: {
            endPoint: mockData.endpoints.baseStagesEndpoint,
            status: httpStatusCodes.NOT_FOUND,
            response: { response: { status: httpStatusCodes.NOT_FOUND } },
          },
        },
      });

      return selectGroupAndFindError('There was an error fetching value stream analytics stages.');
    });

    it('will display an error if the fetchStageData request fails', () => {
      expect(findFlashError()).toBeNull();

      mockRequestCycleAnalyticsData({
        mockFetchStageData: false,
      });

      return selectGroupAndFindError('There was an error fetching data for the selected stage');
    });

    it('will display an error if the fetchTopRankedGroupLabels request fails', () => {
      expect(findFlashError()).toBeNull();

      mockRequestCycleAnalyticsData({ mockFetchTopRankedGroupLabels: false });

      return selectGroupAndFindError(
        'There was an error fetching the top labels for the selected group',
      );
    });

    it('will display an error if the fetchTasksByTypeData request fails', () => {
      expect(findFlashError()).toBeNull();

      mockRequestCycleAnalyticsData({ mockFetchTasksByTypeData: false });

      return selectGroupAndFindError(
        'There was an error fetching data for the tasks by type chart',
      );
    });

    it('will display an error if the fetchStageMedian request fails', () => {
      expect(findFlashError()).toBeNull();

      mockRequestCycleAnalyticsData({
        mockFetchStageMedian: false,
      });

      wrapper.vm.onGroupSelect(mockData.group);

      return waitForPromises().catch(() => {
        expect(findFlashError().innerText.trim()).toEqual(
          'There was an error while fetching value stream analytics data.',
        );
      });
    });
  });

  describe('Url parameters', () => {
    const fakeGroup = {
      id: 2,
      path: 'new-test',
      fullPath: 'new-test-group',
      name: 'New test group',
    };

    const defaultParams = {
      created_after: toYmd(mockData.startDate),
      created_before: toYmd(mockData.endDate),
      group_id: selectedGroup.fullPath,
      project_ids: null,
    };

    const selectedProjectIds = mockData.selectedProjects.map(({ id }) => id);

    beforeEach(() => {
      commonUtils.historyPushState = jest.fn();
      urlUtils.mergeUrlParams = jest.fn();

      mock = new MockAdapter(axios);
      wrapper = createComponent();

      wrapper.vm.$store.dispatch('initializeCycleAnalytics', initialCycleAnalyticsState);
    });

    it('sets the created_after and created_before url parameters', async () => {
      await shouldMergeUrlParams(wrapper, defaultParams);
    });

    describe('with hideGroupDropDown=true', () => {
      beforeEach(() => {
        commonUtils.historyPushState = jest.fn();
        urlUtils.mergeUrlParams = jest.fn();

        mock = new MockAdapter(axios);

        wrapper = createComponent({
          props: {
            hideGroupDropDown: true,
          },
        });

        wrapper.vm.$store.dispatch('initializeCycleAnalytics', {
          ...initialCycleAnalyticsState,
          group: fakeGroup,
        });
      });

      it('sets the group_id url parameter', async () => {
        await shouldMergeUrlParams(wrapper, {
          ...defaultParams,
          created_after: toYmd(mockData.startDate),
          created_before: toYmd(mockData.endDate),
          group_id: null,
        });
      });
    });

    describe('with a group selected', () => {
      beforeEach(() => {
        wrapper.vm.$store.dispatch('setSelectedGroup', {
          ...fakeGroup,
        });
      });

      it('sets the group_id url parameter', async () => {
        await shouldMergeUrlParams(wrapper, {
          ...defaultParams,
          group_id: fakeGroup.fullPath,
        });
      });
    });

    describe('with a group and selectedProjectIds set', () => {
      beforeEach(() => {
        wrapper.vm.$store.dispatch('setSelectedGroup', {
          ...selectedGroup,
        });

        wrapper.vm.$store.dispatch('setSelectedProjects', mockData.selectedProjects);
        return wrapper.vm.$nextTick();
      });

      it('sets the project_ids url parameter', async () => {
        await shouldMergeUrlParams(wrapper, {
          ...defaultParams,
          created_after: toYmd(mockData.startDate),
          created_before: toYmd(mockData.endDate),
          group_id: selectedGroup.fullPath,
          project_ids: selectedProjectIds,
        });
      });
    });
  });
});
