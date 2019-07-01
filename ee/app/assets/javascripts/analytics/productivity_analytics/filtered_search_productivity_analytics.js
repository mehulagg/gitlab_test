import ProductivityAnalyticsFilteredSearchTokenKeys from '~/filtered_search/productivity_analytics_filtered_search_token_keys';
import FilteredSearchManager from '~/filtered_search/filtered_search_manager';

export default class FilteredSearchIssueAnalytics extends FilteredSearchManager {
  constructor() {
    super({
      page: 'productivity_analytics',
      isGroupDecendent: true,
      stateFiltersSelector: '.issues-state-filters',
      isGroup: false,
      filteredSearchTokenKeys: ProductivityAnalyticsFilteredSearchTokenKeys,
    });

    this.isHandledAsync = true;
  }
}
