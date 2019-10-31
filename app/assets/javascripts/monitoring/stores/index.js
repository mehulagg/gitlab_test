import Vue from 'vue';
import Vuex from 'vuex';
import * as actions from './actions';
import mutations from './mutations';
import state from './state';

Vue.use(Vuex);

export default createStore = (baseState = {}) =>
  new Vuex.Store({
    modules: {
      monitoringDashboard: {
        namespaced: true,
        actions,
        mutations,
        state,
        ...baseState,
      },
    },
  });