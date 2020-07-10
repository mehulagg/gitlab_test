import axios from 'axios';
import MockAdapter from 'axios-mock-adapter';
import httpStatusCodes from '~/lib/utils/http_status';
import createFlash from '~/flash';
import testAction from 'helpers/vuex_action_helper';
import * as actions from 'ee/analytics/reports/store/modules/chart/actions';
import { seriesData, configData, pageData } from 'ee_jest/analytics/reports/mock_data';

jest.mock('~/flash');

describe('Reports chart actions', () => {
  let state;
  let mock;

  beforeEach(() => {
    state = { page: { ...pageData, config: configData } };
    mock = new MockAdapter(axios);
  });

  afterEach(() => {
    state = null;
    mock.restore();
  });

  it.each`
    action                             | type                                   | payload
    ${'requestChartSeriesData'}        | ${'REQUEST_CHART_SERIES_DATA'}         | ${null}
    ${'receiveChartSeriesDataSuccess'} | ${'RECEIVE_CHART_SERIES_DATA_SUCCESS'} | ${seriesData}
    ${'receiveChartSeriesDataError'}   | ${'RECEIVE_CHART_SERIES_DATA_ERROR'}   | ${null}
  `('$action commits mutation $type with $payload', ({ action, type, payload }) => {
    return testAction(
      actions[action],
      payload,
      state,
      [payload ? { type, payload } : { type }],
      [],
    );
  });

  describe('receiveChartSeriesDataError', () => {
    it('displays an error message', () => {
      actions.receiveChartSeriesDataError({ commit: jest.fn() });

      expect(createFlash).toHaveBeenCalledWith(
        'There was an error while fetching chart series data.',
      );
    });
  });

  describe('fetchChartSeriesData', () => {
    describe('success', () => {
      beforeEach(() => {
        mock.onGet().reply(httpStatusCodes.OK, seriesData);
      });

      it('dispatches the "requestChartSeriesData" and "receiveChartSeriesDataSuccess" actions', () => {
        return testAction(
          actions.fetchChartSeriesData,
          null,
          state,
          [],
          [
            { type: 'requestChartSeriesData' },
            { type: 'receiveChartSeriesDataSuccess', payload: seriesData },
          ],
        );
      });
    });

    describe('failure', () => {
      beforeEach(() => {
        mock.onGet().reply(httpStatusCodes.NOT_FOUND);
      });

      it('dispatches the "requestChartSeriesData" and "receiveChartSeriesDataError" actions', () => {
        return testAction(
          actions.fetchChartSeriesData,
          null,
          state,
          [],
          [{ type: 'requestChartSeriesData' }, { type: 'receiveChartSeriesDataError' }],
        );
      });
    });
  });
});
