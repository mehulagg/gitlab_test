import { getByIdentifier } from '~/diffs/store/diff_file';

function freeze(thing) {
  return Object.freeze(thing);
}

describe('DiffFile utilities', () => {
  describe('getByIdentifier', () => {
    const SHA1 = '2c20f4f1829ab02411cf31891e09809acca759f2';
    const DIFF_FILES = freeze([
      freeze({ testId: 'alpha', file_hash: SHA1 }),
      freeze({ testId: 'beta', file_hash: 'file_hash' }),
      freeze({ testId: 'gamma', file_path: 'file_path' }),
    ]);

    it.each`
      identifier                                    | findFile
      ${'2c20f4f1829ab02411cf31891e09809acca759f2'} | ${'alpha'}
      ${'file_hash'}                                | ${'beta'}
      ${'file_path'}                                | ${'gamma'}
    `(
      'finds the correct file when given the identifier $identifier',
      ({ identifier, findFile }) => {
        const file = getByIdentifier({ diffFiles: DIFF_FILES, identifier });

        expect(file.testId).toEqual(findFile);
      },
    );
  });
});
