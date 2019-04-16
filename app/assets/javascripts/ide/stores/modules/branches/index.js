import state from './state';
import actions from './actions';
import mutations from './mutations';

export default {
  namespaced: true,
  state: state(),
  actions,
  mutations,
};
