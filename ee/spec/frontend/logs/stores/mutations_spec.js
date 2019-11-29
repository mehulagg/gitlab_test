import mutations from 'ee/logs/stores/mutations';
import * as types from 'ee/logs/stores/mutation_types';

import logsPageState from 'ee/logs/stores/state';
import { mockFilters, mockPods, mockPodName, mockLines } from '../mock_data';

describe('Logs Store Mutations', () => {
  let state;

  beforeEach(() => {
    state = logsPageState();
  });

  it('ensures mutation types are correctly named', () => {
    Object.keys(types).forEach(k => {
      expect(k).toEqual(types[k]);
    });
  });

  describe('REQUEST_FILTERS_DATA', () => {
    it('inits data', () => {
      mutations[types.REQUEST_FILTERS_DATA](state);
      expect(state.filters.data).toEqual([]);
      expect(state.filters.isLoading).toEqual(true);
      expect(state.pods.options).toEqual([]);
      expect(state.pods.current).toEqual(null);
    });
  });

  describe('RECEIVE_FILTERS_DATA_SUCCESS', () => {
    it('receives filters data and stores it as data', () => {
      expect(state.filters.data).toEqual([]);

      mutations[types.RECEIVE_FILTERS_DATA_SUCCESS](state, mockFilters);

      expect(state.filters.data).toEqual(mockFilters);
      expect(state.filters.isLoading).toEqual(false);

      expect(state.pods.options).toEqual(mockPods);
      expect(state.pods.current).toEqual(mockPodName);
    });
    it('receives filters data and stores it as data w/ pre-set pod', () => {
      expect(state.filters.data).toEqual([]);

      [, , state.pods.current] = mockPods;

      mutations[types.RECEIVE_FILTERS_DATA_SUCCESS](state, mockFilters);

      expect(state.filters.data).toEqual(mockFilters);
      expect(state.filters.isLoading).toEqual(false);

      expect(state.pods.options).toEqual(mockPods);
      expect(state.pods.current).toEqual(mockPods[2]);
    });
  });

  describe('RECEIVE_FILTERS_DATA_ERROR', () => {
    it('captures an error loading filters', () => {
      mutations[types.RECEIVE_FILTERS_DATA_ERROR](state);

      expect(state.filters).toEqual({
        data: [],
        isLoading: false,
      });

      expect(state.pods).toEqual({
        options: [],
        current: null,
      });
    });
  });

  describe('REQUEST_LOGS_DATA', () => {
    it('starts loading for logs', () => {
      mutations[types.REQUEST_LOGS_DATA](state);

      expect(state.logs).toEqual(
        expect.objectContaining({
          lines: [],
          isLoading: true,
          isComplete: false,
        }),
      );
    });
  });

  describe('RECEIVE_LOGS_DATA_SUCCESS', () => {
    it('receives logs lines', () => {
      mutations[types.RECEIVE_LOGS_DATA_SUCCESS](state, mockLines);

      expect(state.logs).toEqual(
        expect.objectContaining({
          lines: mockLines,
          isLoading: false,
          isComplete: true,
        }),
      );
    });
  });

  describe('RECEIVE_LOGS_DATA_ERROR', () => {
    it('receives log data error and stops loading', () => {
      mutations[types.RECEIVE_LOGS_DATA_ERROR](state);

      expect(state.logs).toEqual(
        expect.objectContaining({
          lines: [],
          isLoading: false,
          isComplete: true,
        }),
      );
    });
  });

  describe('SET_CURRENT_POD_NAME', () => {
    it('set current pod name', () => {
      mutations[types.SET_CURRENT_POD_NAME](state, mockPodName);

      expect(state.pods.current).toEqual(mockPodName);
    });
  });
});
