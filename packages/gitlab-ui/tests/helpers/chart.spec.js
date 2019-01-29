import defaultConfig, { additiveArrayMerge } from '../../helpers/chart';

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
});
