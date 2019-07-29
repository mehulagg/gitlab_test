import axios from 'axios';
import MockAdapter from 'axios-mock-adapter';
import testAction from 'helpers/vuex_action_helper';
import { TEST_HOST } from 'helpers/test_constants';
import * as actions from 'ee/analytics/cycle_analytics/store/actions';
import * as types from 'ee/analytics/cycle_analytics/store/mutation_types';
import { group, stageData, cycleAnalyticsData } from '../mock_data';

const error = new Error('Request failed with status code 404');

describe('Cycle analytics actions', () => {
  let state;
  let mock;

  beforeEach(() => {
    state = {
      endpoints: {
        cycleAnalyticsData: `${TEST_HOST}/groups/${group.path}/-/cycle_analytics`,
        stageData: `${TEST_HOST}/groups/${group.path}/-/cycle_analytics/events/${cycleAnalyticsData.stats[0].name}.json`,
      },
      stages: [],
    };
    mock = new MockAdapter(axios);
  });

  afterEach(() => {
    mock.restore();
  });

  describe('fetchStageData', () => {
    beforeEach(() => {
      mock.onGet(state.endpoints.stageData).replyOnce(200, stageData);
    });

    it('dispatches receiveStageDataSuccess with received data on success', done => {
      testAction(
        actions.fetchStageData,
        null,
        state,
        [],
        [
          { type: 'requestStageData' },
          {
            type: 'receiveStageDataSuccess',
            payload: { ...stageData },
          },
        ],
        done,
      );
    });

    it('dispatches receiveStageDataError on error', done => {
      const brokenState = {
        ...state,
        endpoints: {
          stageData: 'this will break',
        },
      };

      testAction(
        actions.fetchStageData,
        null,
        brokenState,
        [],
        [
          { type: 'requestStageData' },
          {
            type: 'receiveStageDataError',
            payload: error,
          },
        ],
        done,
      );
    });

    describe('receiveStageDataSuccess', () => {
      it(`commits the ${types.RECEIVE_STAGE_DATA_SUCCESS} mutation`, done => {
        testAction(
          actions.receiveStageDataSuccess,
          { ...stageData },
          state,
          [{ type: types.RECEIVE_STAGE_DATA_SUCCESS, payload: { ...stageData } }],
          [],
          done,
        );
      });
    });

    describe('receiveStageDataError', () => {
      it(`commits the ${types.RECEIVE_STAGE_DATA_ERROR} mutation`, done => {
        testAction(
          actions.receiveStageDataError,
          null,
          state,
          [
            {
              type: types.RECEIVE_STAGE_DATA_ERROR,
            },
          ],
          [],
          done,
        );
      });
    });
  });

  describe('fetchCycleAnalyticsData', () => {
    beforeEach(() => {
      mock.onGet(state.endpoints.cycleAnalyticsData).replyOnce(200, cycleAnalyticsData);
    });

    it('dispatches receiveCycleAnalyticsDataSuccess with received data', done => {
      testAction(
        actions.fetchCycleAnalyticsData,
        null,
        state,
        [],
        [
          { type: 'requestCycleAnalyticsData' },
          {
            type: 'receiveCycleAnalyticsDataSuccess',
            payload: { ...cycleAnalyticsData },
          },
        ],
        done,
      );
    });

    it('dispatches receiveCycleAnalyticsError on error', done => {
      const brokenState = {
        ...state,
        endpoints: {
          cycleAnalyticsData: 'this will break',
        },
      };

      testAction(
        actions.fetchCycleAnalyticsData,
        null,
        brokenState,
        [],
        [
          { type: 'requestCycleAnalyticsData' },
          {
            type: 'receiveCycleAnalyticsDataError',
            payload: error,
          },
        ],
        done,
      );
    });

    describe('receiveCycleAnalyticsDataSuccess', () => {
      // Need to investigate behaviour here as setStageDataEndpoint and fetchStageData should be dispatched too
      it(`commits the ${types.RECEIVE_CYCLE_ANALYTICS_DATA_SUCCESS} mutation`, done => {
        testAction(
          actions.receiveCycleAnalyticsDataSuccess,
          { ...cycleAnalyticsData },
          state,
          [
            {
              type: types.RECEIVE_CYCLE_ANALYTICS_DATA_SUCCESS,
              payload: { ...cycleAnalyticsData },
            },
          ],
          [],
          done,
        );
      });
    });

    describe('receiveCycleAnalyticsDataError', () => {
      it(`commits the ${types.RECEIVE_CYCLE_ANALYTICS_DATA_ERROR} mutation`, done => {
        testAction(
          actions.receiveCycleAnalyticsDataError,
          null,
          state,
          [
            {
              type: types.RECEIVE_CYCLE_ANALYTICS_DATA_ERROR,
            },
          ],
          [],
          done,
        );
      });
    });
  });
});
