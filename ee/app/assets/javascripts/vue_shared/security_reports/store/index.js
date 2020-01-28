import Vue from 'vue';
import Vuex from 'vuex';
import configureMediator from './mediator';
import * as actions from './actions';
import * as getters from './getters';
import mutations from './mutations';
import state from './state';

import moduleFactory from './modules/base';
import messages from './messages';

const { CONTAINER_SCANNING, DAST, DEPENDENCY_SCANNING, SAST } = messages;

Vue.use(Vuex);

export default () =>
  new Vuex.Store({
    modules: {
      containerScanning: moduleFactory({
        feedbackPathCategory: 'container_scanning',
        reportType: CONTAINER_SCANNING,
      }),
      dast: moduleFactory({
        feedbackPathCategory: 'dast',
        reportType: DAST,
      }),
      dependencyScanning: moduleFactory({
        feedbackPathCategory: 'dependency_scanning',
        reportType: DEPENDENCY_SCANNING,
      }),
      sast: moduleFactory({
        feedbackPathCategory: 'sast',
        reportType: SAST,
      }),
    },
    actions,
    getters,
    mutations,
    state: state(),
    plugins: [configureMediator],
  });
