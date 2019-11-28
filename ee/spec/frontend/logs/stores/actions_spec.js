import MockAdapter from 'axios-mock-adapter';
import axios from '~/lib/utils/axios_utils';

import testAction from 'helpers/vuex_action_helper';
import * as types from 'ee/logs/stores/mutation_types';
import logsPageState from 'ee/logs/stores/state';
import { setInitData, showPodLogs, fetchFilters, fetchLogs } from 'ee/logs/stores/actions';

import flash from '~/flash';

import {
  mockProjectPath,
  mockPodName,
  mockFiltersEndpoint,
  mockClusters,
  mockCluster,
  mockFilters,
  mockLines,
  mockNamespace,
} from '../mock_data';

jest.mock('~/flash');

describe('Logs Store actions', () => {
  let state;
  let mock;

  beforeEach(() => {
    state = logsPageState();
  });

  afterEach(() => {
    flash.mockClear();
  });

  describe('setInitData', () => {
    it('should commit environment and pod name mutation', done => {
      testAction(
        setInitData,
        {
          projectPath: mockProjectPath,
          podName: mockPodName,
          filtersPath: mockFiltersEndpoint,
          clusters: mockClusters,
          cluster: mockCluster,
        },
        state,
        [
          { type: types.SET_PROJECT_PATH, payload: mockProjectPath },
          { type: types.SET_FILTERS_PATH, payload: mockFiltersEndpoint },
          { type: types.SET_CLUSTER_LIST, payload: mockClusters },
          { type: types.SET_CLUSTER_NAME, payload: mockCluster },
          { type: types.SET_CURRENT_POD_NAME, payload: mockPodName },
        ],
        [{ type: 'fetchFilters' }],
        done,
      );
    });
  });

  describe('showPodLogs', () => {
    it('should commit pod name', done => {
      testAction(
        showPodLogs,
        mockPodName,
        state,
        [{ type: types.SET_CURRENT_POD_NAME, payload: mockPodName }],
        [{ type: 'fetchLogs' }],
        done,
      );
    });
  });

  describe('fetchFilters', () => {
    beforeEach(() => {
      mock = new MockAdapter(axios);
    });

    afterEach(() => {
      mock.reset();
    });

    it('should commit RECEIVE_FILTERS_DATA_SUCCESS mutation on correct data', done => {
      state.filtersPath = mockFiltersEndpoint;
      state.clusters.current = mockCluster;

      mock
        .onGet(mockFiltersEndpoint, { params: { cluster: mockCluster } })
        .replyOnce(200, mockFilters);

      testAction(
        fetchFilters,
        null,
        state,
        [
          { type: types.REQUEST_FILTERS_DATA },
          { type: types.RECEIVE_FILTERS_DATA_SUCCESS, payload: mockFilters },
        ],
        [{ type: 'fetchLogs' }],
        done,
      );
    });

    it('should commit RECEIVE_FILTERS_DATA_ERROR on wrong data', done => {
      state.filtersPath = mockFiltersEndpoint;
      state.clusters.current = mockCluster;

      mock.onGet(mockFiltersEndpoint, { params: { cluster: mockCluster } }).replyOnce(500);
      testAction(
        fetchFilters,
        mockFiltersEndpoint,
        state,
        [{ type: types.REQUEST_FILTERS_DATA }, { type: types.RECEIVE_FILTERS_DATA_ERROR }],
        [],
        () => {
          expect(flash).toHaveBeenCalledTimes(1);
          done();
        },
      );
    });
  });

  describe('fetchLogs', () => {
    beforeEach(() => {
      mock = new MockAdapter(axios);
    });

    afterEach(() => {
      mock.reset();
    });

    it('should commit logs and pod data when there is pod name defined', done => {
      state.projectPath = mockProjectPath;
      state.clusters.current = mockCluster;
      state.pods.current = mockPodName;
      state.filters.data = mockFilters;

      const endpoint = `/${mockProjectPath}/logs.json`;

      mock
        .onGet(endpoint, {
          params: { cluster: mockCluster, namespace: mockNamespace, pod_name: mockPodName },
        })
        .reply(200, {
          logs: mockLines,
        });

      mock.onGet(endpoint).replyOnce(202); // mock reactive cache

      testAction(
        fetchLogs,
        null,
        state,
        [
          { type: types.REQUEST_LOGS_DATA },
          { type: types.RECEIVE_LOGS_DATA_SUCCESS, payload: mockLines },
        ],
        [],
        done,
      );
    });

    it('should commit logs and pod data when no pod name defined', done => {
      state.projectPath = mockProjectPath;
      state.clusters.current = mockCluster;
      state.filters.data = mockFilters;

      const endpoint = `/${mockProjectPath}/logs.json`;

      mock.onGet(endpoint, { params: { cluster: mockCluster } }).reply(200, {
        logs: mockLines,
      });
      mock.onGet(endpoint).replyOnce(202); // mock reactive cache

      testAction(
        fetchLogs,
        null,
        state,
        [
          { type: types.REQUEST_LOGS_DATA },
          { type: types.RECEIVE_LOGS_DATA_SUCCESS, payload: mockLines },
        ],
        [],
        done,
      );
    });

    it('should commit logs and pod errors when backend fails', done => {
      state.projectPath = mockProjectPath;
      state.clusters.current = mockCluster;
      state.filters.data = mockFilters;

      const endpoint = `/${mockProjectPath}/logs.json`;

      mock.onGet(endpoint, { params: { cluster: mockCluster } }).replyOnce(500);

      testAction(
        fetchLogs,
        null,
        state,
        [{ type: types.REQUEST_LOGS_DATA }, { type: types.RECEIVE_LOGS_DATA_ERROR }],
        [],
        () => {
          expect(flash).toHaveBeenCalledTimes(1);
          done();
        },
      );
    });
  });
});
