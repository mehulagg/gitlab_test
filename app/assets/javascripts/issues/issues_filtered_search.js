import IssuableFilteredSearchTokenKeys from 'ee_else_ce/filtered_search/issuable_filtered_search_token_keys';
import IssuableFilteredSearchTokenKeysCE from '~/filtered_search/issuable_filtered_search_token_keys';
import { FILTERED_SEARCH } from '~/pages/constants';
import FilteredSearchManager from '~/filtered_search/filtered_search_manager';
import { historyPushState, getPagePath } from '~/lib/utils/common_utils';
import { DASHBOARD_PAGE_NAME } from './constants';
import issuesListStore from './stores';

const isInDashboardPage = getPagePath() === DASHBOARD_PAGE_NAME;
const filteredSearchTokenKeys = isInDashboardPage
  ? IssuableFilteredSearchTokenKeysCE
  : IssuableFilteredSearchTokenKeys;

if (!isInDashboardPage) {
  IssuableFilteredSearchTokenKeys.addExtraTokensForIssues();
}

export default class FilteredSearchIssueAnalytics extends FilteredSearchManager {
  constructor() {
    super({
      page: FILTERED_SEARCH.ISSUES,
      isGroup: !isInDashboardPage,
      isGroupDecendent: !isInDashboardPage,
      filteredSearchTokenKeys,
    });

    this.isHandledAsync = true;
  }

  updateObject = path => {
    historyPushState(path);

    issuesListStore.dispatch('issuesList/setFilters', path);
    issuesListStore.dispatch('issuesList/setCurrentPage', 1);
  };
}
