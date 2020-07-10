import * as getters from 'ee/analytics/reports/store/modules/chart/getters';
import {
  seriesData,
  seriesInfo,
  formattedColumnChartData,
} from 'ee_jest/analytics/reports/mock_data';

describe('Reports chart getters', () => {
  let state;

  afterEach(() => {
    state = null;
  });

  describe('displayChart', () => {
    it.each`
      isLoading | error    | expected
      ${true}   | ${false} | ${false}
      ${true}   | ${true}  | ${false}
      ${false}  | ${true}  | ${false}
      ${false}  | ${false} | ${true}
    `(
      'with isLoading=$isLoading and error=$error returns $expected',
      ({ isLoading, error, expected }) => {
        state = {
          isLoading,
          error,
        };

        expect(getters.displayChart(state)).toBe(expected);
      },
    );
  });

  describe('columnChartData', () => {
    it('returns the formatted chart data', () => {
      state = {
        data: {
          ...seriesData,
        },
      };

      expect(getters.columnChartData(state)).toStrictEqual(formattedColumnChartData);
    });
  });

  describe('seriesInfo', () => {
    it('returns the formatted series info', () => {
      state = {
        data: {
          ...seriesData,
        },
      };

      expect(getters.seriesInfo(state)).toStrictEqual(seriesInfo);
    });
  });
});
