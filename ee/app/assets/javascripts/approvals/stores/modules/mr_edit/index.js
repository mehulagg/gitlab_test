import base from '../base';
import actions from './actions';
import mutations from './mutations';
import createState from './state';

export default () => ({
  ...base(),
  state: createState(),
  actions,
  mutations,
});
