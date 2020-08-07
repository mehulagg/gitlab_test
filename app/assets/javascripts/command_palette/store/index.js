import Vue from 'vue';
import Vuex from 'vuex';
import state from './state';
import * as actions from './actions';
import mutations from './mutations';
import { __ } from '~/locale';

Vue.use(Vuex);

// eslint-disable-next-line import/prefer-default-export
console.log(__('building a store'));

export default new Vuex.Store({
  actions,
  state,
  mutations,
});
