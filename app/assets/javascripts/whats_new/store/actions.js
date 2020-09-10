import * as types from './mutation_types';
import * as constants from '../constants';

export default {
  closeDrawer({ commit }) {
    commit(types.CLOSE_DRAWER);
  },
  openDrawer({ commit }, storageKey) {
    commit(types.OPEN_DRAWER);

    localStorage.setItem(storageKey, JSON.stringify(false));
  },
};
