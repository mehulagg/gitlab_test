import Stats from 'ee/stats';
import * as types from './mutation_types';

export default {
  setFilter: ({ commit }, payload) => {
    commit(types.SET_FILTER, payload);

    Stats.trackEvent(document.body.dataset.page, 'set_filter', {
      label: payload.filterId,
      value: payload.optionId,
    });
  },

  setFilterOptions: ({ commit }, payload) => {
    commit(types.SET_FILTER_OPTIONS, payload);
  },

  setAllFilters: ({ commit }, payload) => {
    commit(types.SET_ALL_FILTERS, payload);
  },
};
