import * as types from './mutation_types';
import * as constants from '../constants';

export default {
  [types.CLOSE_DRAWER](state) {
    state.open = false;
  },
  [types.OPEN_DRAWER](state) {
    state.open = true;
    state.displayNotification = false;
  },
  [types.SET_DISPLAY_NOTIFICATION](state, displayNotification) {
    state.displayNotification =  displayNotification;
  },
  [types.SET_STORAGE_KEY](state, version) {
    state.storageKey = constants.STORAGE_KEY + '-' + version;
  }
};
