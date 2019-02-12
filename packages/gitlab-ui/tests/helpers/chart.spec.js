import defaultConfig, { additiveArrayMerge, getThresholdConfig } from '../../helpers/chart';

describe('chart helpers', () => {
  describe('default chart configuration', () => {
    it('applies default color scheme', () => {
      expect(defaultConfig.color).toEqual(['#1F78D1', '#1aaa55', '#fc9403', '#6666c4']);
    });
  });

  describe('additiveArrayMerge', () => {
    it('concatenates arguments if the first is an array', () => {
      expect(additiveArrayMerge([], 1)).toEqual([1]);
    });

    it('returns undefined when first value is not an array', () => {
      expect(additiveArrayMerge(1, [])).toEqual(undefined);
    });
  });

  describe('getThresholdConfig', () => {
    it('returns empty object for no thresholds', () => {
      expect(getThresholdConfig({})).toEqual({});
    });

    it('draws area below line for < threshold', () => {
      const threshold = 3;
      const thresholds = {
        1: {
          operator: '<',
          threshold,
        },
      };
      const expectedLineData = [
        [{ xAxis: 'min', yAxis: threshold }, { xAxis: 'max', yAxis: threshold }],
      ];
      const expectedAreaData = [
        [{ xAxis: 'min', yAxis: Number.NEGATIVE_INFINITY }, { xAxis: 'max', yAxis: threshold }],
      ];

      const { markLine, markArea } = getThresholdConfig(thresholds);

      expect(markLine.data).toEqual(expectedLineData);
      expect(markArea.data).toEqual(expectedAreaData);
    });

    it('draws line only for = threshold', () => {
      const threshold = 7;
      const thresholds = {
        1: {
          operator: '=',
          threshold,
        },
      };
      const expectedLineData = [
        [{ xAxis: 'min', yAxis: threshold }, { xAxis: 'max', yAxis: threshold }],
      ];
      const expectedAreaData = [];

      const { markLine, markArea } = getThresholdConfig(thresholds);

      expect(markLine.data).toEqual(expectedLineData);
      expect(markArea.data).toEqual(expectedAreaData);
    });

    it('draws area above line for > threshold', () => {
      const threshold = 9000;
      const thresholds = {
        1: {
          operator: '>',
          threshold,
        },
      };
      const expectedLineData = [
        [{ xAxis: 'min', yAxis: threshold }, { xAxis: 'max', yAxis: threshold }],
      ];
      const expectedAreaData = [
        [{ xAxis: 'min', yAxis: threshold }, { xAxis: 'max', yAxis: Infinity }],
      ];

      const { markLine, markArea } = getThresholdConfig(thresholds);

      expect(markLine.data).toEqual(expectedLineData);
      expect(markArea.data).toEqual(expectedAreaData);
    });
  });
});
