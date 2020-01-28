import Vue from 'vue';
import Vuex from 'vuex';
import configureMediator from './mediator';
import * as actions from './actions';
import * as getters from './getters';
import mutations from './mutations';
import state from './state';

import containerScanning from './modules/containerScanning';
import dast from './modules/dast';
import dependencyScanning from './modules/dependencyScanning';
import sast from './modules/sast';

Vue.use(Vuex);

export default () =>
  new Vuex.Store({
    modules: {
      containerScanning,
      dast,
      dependencyScanning,
      sast,
    },
    actions,
    getters,
    mutations,
    state: state(),
    plugins: [configureMediator],
  });
