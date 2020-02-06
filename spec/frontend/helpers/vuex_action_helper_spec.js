import MockAdapter from 'axios-mock-adapter';
import { TEST_HOST } from 'helpers/test_constants';
import axios from '~/lib/utils/axios_utils';
import testAction from './vuex_action_helper';

describe('VueX test helper (testAction)', () => {
  let mock;
  const noop = () => {};

  beforeEach(() => {
    mock = new MockAdapter(axios);
  });

  afterEach(() => {
    mock.restore();
  });

  it('properly passes state and payload to action', () => {
    const exampleState = { FOO: 12, BAR: 3 };
    const examplePayload = { BAZ: 73, BIZ: 55 };

    const action = ({ state }, payload) => {
      expect(state).toEqual(exampleState);
      expect(payload).toEqual(examplePayload);
    };

    return testAction(action, examplePayload, exampleState);
  });

  describe('given a sync action', () => {
    it('mocks committing mutations', () => {
      const action = ({ commit }) => {
        commit('MUTATION');
      };

      const assertion = { mutations: [{ type: 'MUTATION' }], actions: [] };

      testAction(action, null, {}, assertion.mutations, assertion.actions, noop);
    });

    it('mocks dispatching actions', () => {
      const action = ({ dispatch }) => {
        dispatch('ACTION');
      };

      const assertion = { actions: [{ type: 'ACTION' }], mutations: [] };

      testAction(action, null, {}, assertion.mutations, assertion.actions, noop);
    });

    it('works with done callback once finished', done => {
      const assertion = { mutations: [], actions: [] };

      testAction(noop, null, {}, assertion.mutations, assertion.actions, done);
    });

    it('returns a promise', done => {
      const assertion = { mutations: [], actions: [] };

      testAction(noop, null, {}, assertion.mutations, assertion.actions)
        .then(done)
        .catch(done.fail);
    });
  });

  describe('given an async action (returning a promise)', () => {
    let lastError;

    const asyncAction = ({ commit, dispatch }) => {
      dispatch('ACTION');

      return axios
        .get(TEST_HOST)
        .catch(error => {
          commit('ERROR');
          lastError = error;
          throw error;
        })
        .then(() => {
          commit('SUCCESS');
        });
    };

    beforeEach(() => {
      lastError = null;
    });

    it('works with done callback once finished', done => {
      mock.onGet(TEST_HOST).replyOnce(200, 42);

      const assertion = { mutations: [{ type: 'SUCCESS' }], actions: [{ type: 'ACTION' }] };

      testAction(asyncAction, null, {}, assertion.mutations, assertion.actions, done);
    });

    it('fails spec if action returns data', () => {
      mock.onGet(TEST_HOST).replyOnce(200, 42);

      const badAction = () => Promise.resolve('something');

      return expect(testAction(badAction, null, {})).rejects.toThrow(
        expect.objectContaining({
          message: expect.stringContaining('toBeUndefined'),
        }),
      );
    });

    it('returns original error of rejected promise while checking actions/mutations', done => {
      mock.onGet(TEST_HOST).replyOnce(500, '');

      const assertion = { mutations: [{ type: 'ERROR' }], actions: [{ type: 'ACTION' }] };

      testAction(asyncAction, null, {}, assertion.mutations, assertion.actions)
        .then(done.fail)
        .catch(error => {
          expect(error).toBe(lastError);
          done();
        });
    });
  });

  it('works with async actions not returning promises', done => {
    const data = { FOO: 'BAR' };

    const asyncAction = ({ commit, dispatch }) => {
      dispatch('ACTION');

      axios
        .get(TEST_HOST)
        .then(() => {
          commit('SUCCESS');
          return data;
        })
        .catch(error => {
          commit('ERROR');
          throw error;
        });
    };

    mock.onGet(TEST_HOST).replyOnce(200, 42);

    const assertion = { mutations: [{ type: 'SUCCESS' }], actions: [{ type: 'ACTION' }] };

    testAction(asyncAction, null, {}, assertion.mutations, assertion.actions, done);
  });
});
