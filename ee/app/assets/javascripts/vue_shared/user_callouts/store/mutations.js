import { SET_ENDPOINT, SET_SHOW_CALLOUT } from './mutations_types';

export default {
  [SET_ENDPOINT](state, endpoint) {
    state.endpoint = endpoint;
  },
  [SET_SHOW_CALLOUT](state, show) {
    state.showCallout = show;
  },
};
