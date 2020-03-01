import MockAdapter from 'axios-mock-adapter';
import axios from '~/lib/utils/axios_utils';
import httpStatus from '~/lib/utils/http_status';
import createFlash from '~/flash';
import testAction from 'helpers/vuex_action_helper';

import * as actions from 'ee/threat_monitoring/store/modules/threat_monitoring_statistics/actions';
import * as types from 'ee/threat_monitoring/store/modules/threat_monitoring_statistics/mutation_types';
import getInitialState from 'ee/threat_monitoring/store/modules/threat_monitoring_statistics/state';

import { mockWafStatisticsResponse } from '../../../mock_data';

jest.mock('~/flash', () => jest.fn());

const statisticsEndpoint = 'statisticsEndpoint';

describe('threatMonitoringStatistics actions', () => {
  let state;

  beforeEach(() => {
    state = getInitialState();
  });

  afterEach(() => {
    createFlash.mockClear();
  });

  describe('requestStatistics', () => {
    it('commits the REQUEST_STATISTICS mutation', () =>
      testAction(
        actions.requestStatistics,
        undefined,
        state,
        [
          {
            type: types.REQUEST_STATISTICS,
          },
        ],
        [],
      ));
  });

  describe('receiveStatisticsSuccess', () => {
    it('commits the RECEIVE_STATISTICS_SUCCESS mutation', () =>
      testAction(
        actions.receiveStatisticsSuccess,
        mockWafStatisticsResponse,
        state,
        [
          {
            type: types.RECEIVE_STATISTICS_SUCCESS,
            payload: mockWafStatisticsResponse,
          },
        ],
        [],
      ));
  });

  describe('receiveStatisticsError', () => {
    it('commits the RECEIVE_STATISTICS_ERROR mutation', () =>
      testAction(
        actions.receiveStatisticsError,
        undefined,
        state,
        [
          {
            type: types.RECEIVE_STATISTICS_ERROR,
          },
        ],
        [],
      ).then(() => {
        expect(createFlash).toHaveBeenCalled();
      }));
  });

  describe('fetchStatistics', () => {
    let mock;
    const currentEnvironmentId = 3;

    beforeEach(() => {
      state.statisticsEndpoint = statisticsEndpoint;
      state.threatMonitoring = { currentEnvironmentId };
      mock = new MockAdapter(axios);
    });

    afterEach(() => {
      mock.restore();
    });

    describe('on success', () => {
      beforeEach(() => {
        jest.spyOn(global.Date, 'now').mockImplementation(() => new Date(2019, 0, 31).getTime());

        mock
          .onGet(statisticsEndpoint, {
            params: {
              environment_id: currentEnvironmentId,
              from: '2019-01-01T00:00:00.000Z',
              to: '2019-01-31T00:00:00.000Z',
              interval: 'day',
            },
          })
          .replyOnce(httpStatus.OK, mockWafStatisticsResponse);
      });

      it('should dispatch the request and success actions', () =>
        testAction(
          actions.fetchStatistics,
          undefined,
          state,
          [],
          [
            { type: 'requestStatistics' },
            {
              type: 'receiveStatisticsSuccess',
              payload: mockWafStatisticsResponse,
            },
          ],
        ));
    });

    describe('on NOT_FOUND', () => {
      beforeEach(() => {
        mock.onGet(statisticsEndpoint).replyOnce(httpStatus.NOT_FOUND);
      });

      it('should dispatch the request and success action with empty data', () =>
        testAction(
          actions.fetchStatistics,
          undefined,
          state,
          [],
          [
            { type: 'requestStatistics' },
            {
              type: 'receiveStatisticsSuccess',
              payload: expect.objectContaining({
                total: 0,
                anomalous: 0,
                history: {
                  nominal: [],
                  anomalous: [],
                },
              }),
            },
          ],
        ));
    });

    describe('on error', () => {
      beforeEach(() => {
        mock.onGet(statisticsEndpoint).replyOnce(500);
      });

      it('should dispatch the request and error actions', () =>
        testAction(
          actions.fetchStatistics,
          undefined,
          state,
          [],
          [{ type: 'requestStatistics' }, { type: 'receiveStatisticsError' }],
        ));
    });

    describe('with an empty endpoint', () => {
      beforeEach(() => {
        state.statisticsEndpoint = '';
      });

      it('should dispatch receiveStatisticsError', () =>
        testAction(
          actions.fetchStatistics,
          undefined,
          state,
          [],
          [{ type: 'receiveStatisticsError' }],
        ));
    });
  });
});
