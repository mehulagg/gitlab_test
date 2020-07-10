import Vuex from 'vuex';
import page from './modules/page/index';
import chart from './modules/chart/index';

export default () =>
  new Vuex.Store({
    modules: { page, chart },
  });
