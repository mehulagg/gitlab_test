import * as types from './mutation_types';

export default {
  toggleOpen: ({ dispatch, state }, view) => {
    if (state.isOpen) {
      dispatch('close');
    } else {
      dispatch('open', view);
    }
  },

  open: ({ commit }, view) => {
    commit(types.SET_OPEN, true);

    if (view) {
      const { name, keepAlive } = view;

      commit(types.SET_CURRENT_VIEW, name);

      if (keepAlive) {
        commit(types.KEEP_ALIVE_VIEW, name);
      }
    }
  },

  close: ({ commit }) => {
    commit(types.SET_OPEN, false);
  },
};
