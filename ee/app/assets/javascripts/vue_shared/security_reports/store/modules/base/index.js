import state from './state';
import mutations from '../base/mutations';
import * as getters from '../base/getters';
import * as actions from '../base/actions';

export default ({ reportType, feedbackPathCategory }) => ({
  namespaced: true,
  state: () => ({
    reportType,
    feedbackPathCategory,
    ...state(),
  }),
  mutations,
  getters,
  actions,
});
