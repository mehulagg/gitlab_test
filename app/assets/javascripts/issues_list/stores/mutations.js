import * as types from './mutation_types';

export default {
  [types.INCREMENT_INITIALIZED_ISSUABLE_COUNT](state) {
    state.initializedIssuableCount += 1;
  },
};
