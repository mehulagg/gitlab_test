import Vue from 'vue';
import Vuex from 'vuex';

import Poll from '~/lib/utils/poll';
import Visibility from 'visibilityjs';

// import state from './state';
// import mutations from './mutations';
// import * as actions from './actions';

let eTagPoll;

import projectSelectorModule from 'ee/vuex_shared/modules/project_selector';
import axios from '~/lib/utils/axios_utils';

Vue.use(Vuex);

export default () => {
  const store = new Vuex.Store({
    modules: {
      projectSelector: projectSelectorModule(),
    },
    actions: {
      clearProjectsEtagPoll: () => {
        eTagPoll = null;
      },
      stopProjectsPolling: () => {
        if (eTagPoll) eTagPoll.stop();
      },
      restartProjectsPolling: () => {
        if (eTagPoll) eTagPoll.restart();
      },
      forceProjectsRequest: () => {
        if (eTagPoll) eTagPoll.makeRequest();
      },
      fetchPolling({ dispatch, state }) {
        if (eTagPoll) return;

        eTagPoll = new Poll({
          resource: {
            fetchProjects: () => axios.get(state.projectSelector.projectEndpoints.list),
          },
          method: 'fetchProjects',
          successCallback: ({ data }) => dispatch('projectSelector/receiveProjectsSuccess', data),
          errorCallback: () => dispatch('projectSelector/receiveProjectsError'),
        });

        if (!Visibility.hidden()) {
          eTagPoll.makeRequest();
        }

        Visibility.change(() => {
          if (!Visibility.hidden()) {
            dispatch('restartProjectsPolling');
          } else {
            dispatch('stopProjectsPolling');
          }
        });
      },
    },
    // state,
    // mutations,
    // actions,
  });

  return store;
};
