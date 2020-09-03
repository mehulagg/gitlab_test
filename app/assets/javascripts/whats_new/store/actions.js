import * as types from './mutation_types';
import * as constants from '../constants';

export default {
  closeDrawer({ commit }) {
    commit(types.CLOSE_DRAWER);
  },
  openDrawer({ commit, state }) {
    commit(types.OPEN_DRAWER);

    localStorage.setItem(state.storageKey, JSON.stringify(false));
  },
  initStorage({ commit, state }, version) {
    commit(types.SET_STORAGE_KEY, version);

    let displayNotification = JSON.parse(localStorage.getItem(state.storageKey));
    if(displayNotification === null) {
      displayNotification = true;
    }

    commit(types.SET_DISPLAY_NOTIFICATION, displayNotification)
  }
};
