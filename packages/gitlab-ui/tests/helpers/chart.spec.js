import { additiveArrayMerge } from '../../helpers/chart';

describe('chart helpers', () => {
  describe('additiveArrayMerge', () => {
    it('concatenates arguments if the first is an array', () => {
      expect(additiveArrayMerge([], 1)).toEqual([1]);
    });

    it('returns undefined when first value is not an array', () => {
      expect(additiveArrayMerge(1, [])).toEqual(undefined);
    });
  });
});
