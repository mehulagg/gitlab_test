import Vue from 'vue';
import { GlDropdown, GlDropdownItem } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import { scrollDown } from '~/lib/utils/scroll_utils';
import EnvironmentLogs from 'ee/logs/components/environment_logs.vue';

import { createStore } from 'ee/logs/stores';
import {
  mockProjectPath,
  mockCluster,
  mockClusters,
  mockPods,
  mockLines,
  mockPodName,
  mockFiltersEndpoint,
} from '../mock_data';

jest.mock('~/lib/utils/scroll_utils');

describe('EnvironmentLogs', () => {
  let EnvironmentLogsComponent;
  let store;
  let wrapper;
  let state;

  const propsData = {
    projectFullPath: mockProjectPath,
    filtersPath: mockFiltersEndpoint,
    currentClusterName: mockCluster,
  };

  const actionMocks = {
    setInitData: jest.fn(),
    showPodLogs: jest.fn(),
    showCluster: jest.fn(),
    fetchFilters: jest.fn(),
  };

  const updateControlBtnsMock = jest.fn();

  const findClustersDropdown = () => wrapper.find('.js-clusters-dropdown');
  const findPodsDropdown = () => wrapper.find('.js-pods-dropdown');
  const findLogControlButtons = () => wrapper.find({ name: 'log-control-buttons-stub' });
  const findLogTrace = () => wrapper.find('.js-log-trace');

  const initWrapper = () => {
    wrapper = shallowMount(EnvironmentLogsComponent, {
      attachToDocument: true,
      sync: false,
      propsData,
      store,
      stubs: {
        LogControlButtons: {
          name: 'log-control-buttons-stub',
          template: '<div/>',
          methods: {
            update: updateControlBtnsMock,
          },
        },
      },
      methods: {
        ...actionMocks,
      },
    });
  };

  beforeEach(() => {
    store = createStore();
    state = store.state.environmentLogs;
    EnvironmentLogsComponent = Vue.extend(EnvironmentLogs);
  });

  afterEach(() => {
    actionMocks.setInitData.mockReset();
    actionMocks.showPodLogs.mockReset();
    actionMocks.fetchFilters.mockReset();

    if (wrapper) {
      wrapper.destroy();
    }
  });

  it('displays UI elements', () => {
    initWrapper();

    expect(wrapper.isVueInstance()).toBe(true);
    expect(wrapper.isEmpty()).toBe(false);
    expect(findLogTrace().isEmpty()).toBe(false);

    expect(findClustersDropdown().is(GlDropdown)).toBe(true);
    expect(findPodsDropdown().is(GlDropdown)).toBe(true);

    expect(findLogControlButtons().exists()).toBe(true);
  });

  it('mounted inits data', () => {
    initWrapper();

    expect(actionMocks.setInitData).toHaveBeenCalledTimes(1);
    expect(actionMocks.setInitData).toHaveBeenLastCalledWith({
      projectPath: mockProjectPath,
      filtersPath: mockFiltersEndpoint,
      cluster: mockCluster,
      clusters: [],
      podName: null,
    });
  });

  describe('loading state', () => {
    beforeEach(() => {
      state.pods.options = [];

      state.logs.lines = [];
      state.logs.isLoading = true;

      state.filters.data = [];
      state.filters.isLoading = true;

      initWrapper();
    });

    it('displays a disabled pods dropdown', () => {
      expect(findPodsDropdown().attributes('disabled')).toEqual('true');
      expect(findPodsDropdown().findAll(GlDropdownItem).length).toBe(0);
    });

    it('does not update buttons state', () => {
      expect(updateControlBtnsMock).not.toHaveBeenCalled();
    });

    it('shows a logs trace', () => {
      expect(findLogTrace().text()).toBe('');
      expect(
        findLogTrace()
          .find('.js-build-loader-animation')
          .isVisible(),
      ).toBe(true);
    });
  });

  describe('state with data', () => {
    beforeEach(() => {
      actionMocks.setInitData.mockImplementation(() => {
        state.clusters.current = mockCluster;
        state.clusters.options = mockClusters;

        state.pods.options = mockPods;
        state.pods.current = mockPodName;

        state.logs.lines = mockLines;
        state.logs.isComplete = true;
      });
      actionMocks.showPodLogs.mockImplementation(() => {});
      actionMocks.fetchFilters.mockImplementation(() => {});

      initWrapper();
    });

    afterEach(() => {
      scrollDown.mockReset();
      updateControlBtnsMock.mockReset();

      actionMocks.setInitData.mockReset();
      actionMocks.showPodLogs.mockReset();
      actionMocks.fetchFilters.mockReset();
    });

    it('populates clusters dropdown', () => {
      const items = findClustersDropdown().findAll(GlDropdownItem);
      expect(findClustersDropdown().props('text')).toBe(mockCluster);
      expect(items.length).toBe(mockClusters.length);
      mockClusters.forEach((clusters, i) => {
        const item = items.at(i);
        expect(item.text()).toBe(clusters);
      });
    });

    it('populates pods dropdown', () => {
      const items = findPodsDropdown().findAll(GlDropdownItem);

      expect(findPodsDropdown().props('text')).toBe(mockPodName);
      expect(items.length).toBe(mockPods.length);
      mockPods.forEach((pod, i) => {
        const item = items.at(i);
        expect(item.text()).toBe(pod);
      });
    });

    it('populates logs trace', () => {
      const trace = findLogTrace();
      expect(trace.text().split('\n').length).toBe(mockLines.length);
      expect(trace.text().split('\n')).toEqual(mockLines);
    });

    it('update control buttons state', () => {
      expect(updateControlBtnsMock).toHaveBeenCalledTimes(1);
    });

    it('scrolls to bottom when loaded', () => {
      expect(scrollDown).toHaveBeenCalledTimes(1);
    });

    describe('when user clicks', () => {
      it('environment name, trace is refreshed', () => {
        const items = findClustersDropdown().findAll(GlDropdownItem);
        const index = 1; // any env

        expect(actionMocks.showCluster).toHaveBeenCalledTimes(0);

        items.at(index).vm.$emit('click');

        expect(actionMocks.showCluster).toHaveBeenCalledTimes(1);
        expect(actionMocks.showCluster).toHaveBeenLastCalledWith(mockClusters[index]);
      });

      it('pod name, trace is refreshed', () => {
        const items = findPodsDropdown().findAll(GlDropdownItem);
        const index = 2; // any pod

        expect(actionMocks.showPodLogs).toHaveBeenCalledTimes(0);

        items.at(index).vm.$emit('click');

        expect(actionMocks.showPodLogs).toHaveBeenCalledTimes(1);
        expect(actionMocks.showPodLogs).toHaveBeenLastCalledWith(mockPods[index]);
      });

      it('refresh button, trace is refreshed', () => {
        expect(actionMocks.showPodLogs).toHaveBeenCalledTimes(0);

        findLogControlButtons().vm.$emit('refresh');

        expect(actionMocks.showPodLogs).toHaveBeenCalledTimes(1);
        expect(actionMocks.showPodLogs).toHaveBeenLastCalledWith(mockPodName);
      });
    });
  });
});
