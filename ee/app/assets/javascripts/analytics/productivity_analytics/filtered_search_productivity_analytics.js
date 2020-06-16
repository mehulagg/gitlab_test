import ProductivityAnalyticsFilteredSearchTokenKeys from './productivity_analytics_filtered_search_token_keys';
import FilteredSearchManager from 'ee_else_ce/filtered_search/filtered_search_manager';
import { urlParamsToObject } from '~/lib/utils/common_utils';
import { __ } from '~/locale';
import store from './store';

export default class FilteredSearchProductivityAnalytics extends FilteredSearchManager {
  constructor({ isGroup = true }) {
    super({
      page: 'productivity_analytics',
      isGroupDecendent: true,
      stateFiltersSelector: '.issues-state-filters',
      isGroup,
      filteredSearchTokenKeys: ProductivityAnalyticsFilteredSearchTokenKeys,
      placeholder: __('Filter results...'),
    });

    this.isHandledAsync = true;
  }

  /**
   * Updates filters in productivity analytics store
   */
  updateObject = path => {
    const filters = urlParamsToObject(path);
    store.dispatch('filters/setFilters', filters);
  };
}
