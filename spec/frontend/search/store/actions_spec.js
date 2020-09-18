import testAction from 'helpers/vuex_action_helper';
import * as actions from '~/search/store/actions';
import * as types from '~/search/store/mutation_types';
import createState from '~/search/store/state';

describe('GlobalSearch Store Actions', () => {
  let state;

  beforeEach(() => {
    state = createState();
  });

  describe('fetchSearch', () => {
    it('should commit mutation REQUEST_SEARCH', done => {
      testAction(actions.fetchSearch, null, state, [{ type: types.REQUEST_SEARCH }], [], done);
    });
  });
});
