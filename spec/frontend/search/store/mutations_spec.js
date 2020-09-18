import mutations from '~/search/store/mutations';
import createState from '~/search/store/state';
import * as types from '~/search/store/mutation_types';

describe('GlobalSearch Store Mutations', () => {
  let state;
  beforeEach(() => {
    state = createState();
  });

  describe('REQUEST_SEARCH', () => {
    beforeEach(() => {
      mutations[types.REQUEST_SEARCH](state);
    });

    it('sets isLoading to true', () => {
      expect(state.isLoading).toEqual(true);
    });
  });

  describe('RECEIVE_SEARCH_SUCCESS', () => {
    const mockRes = [1, 2, 3];

    beforeEach(() => {
      mutations[types.RECEIVE_SEARCH_SUCCESS](state, mockRes);
    });

    it('sets isLoading to false', () => {
      expect(state.isLoading).toEqual(false);
    });

    it('sets results to response', () => {
      expect(state.results).toBe(mockRes);
    });
  });

  describe('RECEIVE_SEARCH_ERROR', () => {
    beforeEach(() => {
      mutations[types.RECEIVE_SEARCH_ERROR](state);
    });

    it('sets isLoading to false', () => {
      expect(state.isLoading).toEqual(false);
    });

    it('sets results to []', () => {
      expect(state.results).toEqual([]);
    });
  });
});
