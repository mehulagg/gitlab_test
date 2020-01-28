import state from './state';
import mutations from '../base/mutations';
import * as getters from '../base/getters';
import * as actions from '../base/actions';

export default {
  namespaced: true,
  state,
  mutations,
  getters,
  actions,
};
