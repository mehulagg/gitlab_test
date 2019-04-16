import { sprintf, __ } from '~/locale';

export default {
  getFilter: state => filterId => state.filters.find(filter => filter.id === filterId),

  getSelectedOptions: (state, getters) => filterId => {
    const filter = getters.getFilter(filterId);
    return filter.options.filter(option => filter.selection.has(option.id));
  },

  getSelectedOptionNames: (state, getters) => filterId => {
    const selectedOptions = getters.getSelectedOptions(filterId);
    const extraOptionCount = selectedOptions.length - 1;
    const firstOption = selectedOptions.map(option => option.name)[0];

    return {
      firstOption,
      extraOptionCount: extraOptionCount
        ? sprintf(__('+%{extraOptionCount} more'), { extraOptionCount })
        : '',
    };
  },

  /**
   * Loops through all the filters and returns all the active ones
   * stripping out any that are set to 'all'
   * @returns Object
   * e.g. { type: ['sast'], severity: ['high', 'medium'] }
   */
  activeFilters: state =>
    state.filters.reduce((acc, filter) => {
      acc[filter.id] = [...filter.selection].filter(option => option !== 'all');
      return acc;
    }, {}),
};
