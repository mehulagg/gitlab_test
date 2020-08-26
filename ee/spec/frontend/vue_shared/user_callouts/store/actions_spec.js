import MockAdapter from 'axios-mock-adapter';
import { dismissCallout, setShowCallout } from 'ee/vue_shared/user_callouts/store/actions';
import { SET_SHOW_CALLOUT } from 'ee/vue_shared/user_callouts/store/mutations_types';
import state from 'ee/vue_shared/user_callouts/store/state';
import testAction from 'helpers/vuex_action_helper';
import { TEST_HOST } from 'spec/test_constants';
import axios from '~/lib/utils/axios_utils';

describe('User Callouts Actions', () => {
  let mockedState;

  beforeEach(() => {
    mockedState = state();
  });

  describe('setShowCallout', () => {
    it('should commit SET_SHOW_CALLOUT mutation', done => {
      testAction(
        setShowCallout,
        true,
        mockedState,
        [{ payload: true, type: SET_SHOW_CALLOUT }],
        [],
        done,
      );
    });
  });

  describe('dismissFeatureFlagsCallout', () => {
    const endpoint = `${TEST_HOST}/endpoint.json`;
    const calloutId = 'calloutId';
    let mock;
    beforeEach(() => {
      mock = new MockAdapter(axios);
    });
    afterEach(() => {
      mock.restore();
    });
    describe('success', () => {
      it('should commit SET_SHOW_CALLOUT mutation', done => {
        mock.onPut(endpoint).replyOnce(200);
        testAction(
          dismissCallout,
          { endpoint, calloutId },
          mockedState,
          [],
          [{ payload: false, type: 'setShowCallout' }],
          done,
        );
      });
    });
    describe('error', () => {
      it('should commit SET_SHOW_CALLOUT mutation', done => {
        mock.onPut(endpoint).replyOnce(500);
        testAction(
          dismissCallout,
          { endpoint, calloutId },
          mockedState,
          [],
          [{ payload: false, type: 'setShowCallout' }],
          done,
        );
      });
    });
  });
});
