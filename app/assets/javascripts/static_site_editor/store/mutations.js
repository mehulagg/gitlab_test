import * as types from './mutation_types';
import { LOADING, LOADED, LOADING_ERROR } from '../constants';

export default {
  [types.LOAD_CONTENT](state) {
    state.status = LOADING;
    state.isContentLoaded = false;
  },
  [types.RECEIVE_CONTENT_SUCCESS](state, { title, content }) {
    state.status = LOADED;
    state.title = title;
    state.content = content;
  },
  [types.RECEIVE_CONTENT_ERROR](state) {
    state.status = LOADING_ERROR;
  },
};
