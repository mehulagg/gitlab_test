import * as getters from 'ee/analytics/code_analytics/store/getters';
import httpStatus from '~/lib/utils/http_status';

let state = null;

describe('Code analytics getters', () => {
  describe('hasNoAccessError', () => {
    beforeEach(() => {
      state = {
        errorCode: null,
      };
    });

    it(`returns true if "hasError" is set to ${httpStatus.FORBIDDEN}`, () => {
      state.errorCode = httpStatus.FORBIDDEN;
      expect(getters.hasNoAccessError(state)).toEqual(true);
    });

    it(`returns false if "hasError" is not set to ${httpStatus.FORBIDDEN}`, () => {
      expect(getters.hasNoAccessError(state)).toEqual(false);
    });
  });
});
