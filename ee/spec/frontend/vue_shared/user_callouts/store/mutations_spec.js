import mutations from 'ee/vue_shared/user_callouts/store/mutations';
import { SET_ENDPOINT, SET_SHOW_CALLOUT } from 'ee/vue_shared/user_callouts/store/mutations_types';
import state from 'ee/vue_shared/user_callouts/store/state';

describe('Feature flags Edit Module Mutations', () => {
  let mockedState;

  beforeEach(() => {
    mockedState = state();
  });

  describe('SET_ENDPOINT', () => {
    it('should set endpoint', () => {
      mutations[SET_ENDPOINT](mockedState, 'user_callouts/');
      expect(mockedState.endpoint).toEqual('user_callouts/');
    });
  });

  describe('SET_SHOW_CALLOUT', () => {
    it('should set the provided state', () => {
      mutations[SET_SHOW_CALLOUT](mockedState, true);
      expect(mockedState.showCallout).toBe(true);
    });
  });
});
