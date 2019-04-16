import * as types from './mutation_types';

export default {
  open: ({ commit }, data) => commit(types.OPEN, data),
  close: ({ commit }) => commit(types.CLOSE),
  show: ({ commit }) => commit(types.SHOW),
  hide: ({ commit }) => commit(types.HIDE),
};
