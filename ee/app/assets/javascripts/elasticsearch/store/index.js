import Vue from 'vue';
import Vuex from 'vuex';
import * as types from './mutation_types';

import * as modalTypes from './modal_types';

Vue.use(Vuex);

const indexingModalTypes = [
  modalTypes.PAUSE_INDEXING,
  modalTypes.RESUME_INDEXING,
  modalTypes.REINDEX,
];

const actions = {
  updateIndices({ commit }, data) {
    commit(types.SETUP_INDICES, data);
  },
  markIndexAsClicked({ getters, commit }, id) {
    if (getters.clickedIndex) {
      commit(types.MARK_INDEX_AS_CLICKED, { id: getters.clickedIndex.id, clicked: false });
    }
    commit(types.MARK_INDEX_AS_CLICKED, { id });
  },
  markIndexAsSearchSource({ getters, commit }, id) {
    if (getters.searchSourceIndex) {
      commit(types.MARK_INDEX_AS_SEARCH_SOURCE, {
        id: getters.searchSourceIndex.id,
        source: false,
      });
    }
    commit(types.MARK_INDEX_AS_SEARCH_SOURCE, { id });
  },
  setIndexingStatus({ commit }, status) {
    commit(types.SET_INDEXING_STATUS, status);
  },
  showModal({ commit }, type) {
    commit(types.SET_MODAL_VISIBLE, type);
  },
  hideModal({ commit }) {
    commit(types.SET_MODAL_HIDDEN);
  },
  setInfoMessage({ commit }, msg) {
    commit(types.SET_INFO_MESSAGE, msg);
  },
};
const mutations = {
  [types.SETUP_INDICES](state, indices) {
    state.indices = indices;
  },
  [types.MARK_INDEX_AS_CLICKED](state, { id, clicked = true }) {
    const index = state.indices.find(i => i.id === id);
    Object.assign(index, {
      clicked,
    });

    state.indices = [...state.indices];
  },
  [types.MARK_INDEX_AS_SEARCH_SOURCE](state, { id, source = true }) {
    const index = state.indices.find(i => i.id === id);
    Object.assign(index, {
      active_search_source: source,
    });

    state.indices = [...state.indices];
  },
  [types.SET_INDEXING_STATUS](state, status) {
    state.isIndexing = status;
  },
  [types.SET_MODAL_VISIBLE](state, type) {
    state.modalType = type;
  },
  [types.SET_MODAL_HIDDEN](state) {
    state.modalType = undefined;
  },
  [types.SET_INFO_MESSAGE](state, msg) {
    state.infoMessage = msg;
  },
};
const getters = {
  searchSourceIndex: state => state.indices.find(i => i.active_search_source),
  clickedIndex: state => state.indices.find(i => i.clicked),
  isRemoveModalVisible: state => state.modalType === modalTypes.REMOVE,
  isSwitchSearchModalVisible: state => state.modalType === modalTypes.SWITCH_SEARCH,
  isIndexingModalVisible: state => indexingModalTypes.indexOf(state.modalType) !== -1,
};
const state = {
  indices: [],
  isIndexing: false,
  modalType: undefined,
  infoMessage: {},
};

const createStore = () =>
  new Vuex.Store({
    actions,
    mutations,
    getters,
    state,
  });

export default createStore;
