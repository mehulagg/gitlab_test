import Vue from 'vue';
import Vuex from 'vuex';
import notesModule from './modules';

Vue.use(Vuex);

const notesStore = () => new Vuex.Store(notesModule());

export default notesStore();
