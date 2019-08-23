import {
  median,
  getScatterPlotData,
  getMedianLineData,
} from 'ee/analytics/productivity_analytics/utils';
import { mockScatterplotData } from './mock_data';

describe('Productivity Analytics utils', () => {
  describe('median', () => {
    it('computes the median for a given array with odd length', () => {
      const items = [10, 27, 20, 5, 19];
      expect(median(items)).toBe(19);
    });

    it('computes the median for a given array with even length', () => {
      const items = [10, 27, 20, 5, 19, 4];
      expect(median(items)).toBe(14.5);
    });
  });

  describe('getScatterPlotData', () => {
    it('filters out data before given "dateInPast", transforms the data and sorts by date ascending', () => {
      const dateInPast = '2019-08-09T22:00:00.000Z';
      const result = getScatterPlotData(mockScatterplotData, dateInPast);
      const expected = [
        ['2019-08-09T22:00:00.000Z', 44],
        ['2019-08-10T22:00:00.000Z', 46],
        ['2019-08-11T22:00:00.000Z', 62],
        ['2019-08-12T22:00:00.000Z', 60],
        ['2019-08-13T22:00:00.000Z', 43],
        ['2019-08-14T22:00:00.000Z', 46],
        ['2019-08-15T22:00:00.000Z', 56],
        ['2019-08-16T22:00:00.000Z', 24],
        ['2019-08-17T22:00:00.000Z', 138],
        ['2019-08-18T22:00:00.000Z', 139],
      ];
      expect(result).toEqual(expected);
    });
  });

  describe('getMedianLineData', () => {
    const daysOffset = 10;

    it(`computes the median for every item in the scatterData array for the past ${daysOffset} days`, () => {
      const scatterData = [
        ['2019-08-16T22:00:00.000Z', 24],
        ['2019-08-17T22:00:00.000Z', 138],
        ['2019-08-18T22:00:00.000Z', 139],
      ];
      const result = getMedianLineData(mockScatterplotData, scatterData, daysOffset);
      const expected = [
        ['2019-08-16T22:00:00.000Z', 51],
        ['2019-08-17T22:00:00.000Z', 51],
        ['2019-08-18T22:00:00.000Z', 56],
      ];
      expect(result).toEqual(expected);
    });
  });
});
