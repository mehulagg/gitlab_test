<script>
import { mapActions, mapState, mapGetters } from 'vuex';
import { GlPagination } from '@gitlab/ui';
import IssuableIndex from '~/issuable_index';
import projectSelect from '~/project_select';
import { ISSUABLE_INDEX } from '~/pages/projects/constants';
import { getParameterValues, mergeUrlParams } from '~/lib/utils/url_utility';
import {
  objectToQueryString,
  scrollToElement,
  isInProjectPage,
  isInGroupsPage,
  getPagePath,
} from '~/lib/utils/common_utils';
import Issue from './issue.vue';
import IssuesEmptyState from './empty_state.vue';
import IssuesLoadingState from './loading_state.vue';
import { ISSUE_STATES, ACTIVE_TAB_CLASS, ISSUES_PER_PAGE, DASHBOARD_PAGE_NAME } from '../constants';

const issuableIndex = new IssuableIndex(ISSUABLE_INDEX.ISSUE);

export default {
  components: {
    IssuesLoadingState,
    IssuesEmptyState,
    GlPagination,
    Issue,
  },
  props: {
    endpoint: {
      type: String,
      required: true,
    },
    canBulkUpdate: {
      type: Boolean,
      required: true,
    },
    createPath: {
      type: String,
      required: false,
      default: '',
    },
    filteredSearch: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      ISSUES_PER_PAGE,
      isInGroupsPage: isInGroupsPage(),
      isInProjectPage: isInProjectPage(),
      isInDashboardPage: getPagePath() === DASHBOARD_PAGE_NAME,
      isLoadingDisabled: false,
    };
  },
  computed: {
    ...mapState('issuesList', ['issues', 'loading', 'isBulkUpdating', 'currentPage', 'totalItems']),
    ...mapGetters('issuesList', ['hasFilters', 'appliedFilters']),

    hasIssues() {
      return !this.isLoadingDisabled && !this.loading && this.issues && this.issues.length > 0;
    },
  },
  watch: {
    appliedFilters() {
      this.loadIssues();
      this.updateIssueStateTabs();
    },
    issues() {
      this.setupExternalEvents();
    },
  },
  mounted() {
    this.loadIssues();
    this.updateIssueStateTabs();
    this.setupExternalEvents();

    if (this.isInGroupsPage || this.isInDashboardPage) {
      projectSelect();
    }
  },
  updated() {
    this.setupExternalEvents();
  },
  methods: {
    ...mapActions('issuesList', ['fetchIssues', 'setCurrentPage']),
    getCurrentState() {
      const [state] = getParameterValues('state');
      return state || ISSUE_STATES.OPENED;
    },
    updateIssueStateTabs() {
      const activeTabEl = document.querySelector('.issues-state-filters .active');
      const newActiveTabEl = document.querySelector(
        `.issues-state-filters [data-state="${this.getCurrentState()}"]`,
      );

      if (activeTabEl && !activeTabEl.querySelector(`[data-state="${this.getCurrentState()}"]`)) {
        activeTabEl.classList.remove(ACTIVE_TAB_CLASS);
        newActiveTabEl.parentElement.classList.add(ACTIVE_TAB_CLASS);
      } else if (newActiveTabEl) {
        newActiveTabEl.parentElement.classList.add(ACTIVE_TAB_CLASS);
      }
    },
    setupExternalEvents() {
      if (this.isInProjectPage) {
        issuableIndex.bulkUpdateSidebar.initDomElements();
        issuableIndex.bulkUpdateSidebar.bindEvents();
      }
    },
    updatePage(page) {
      this.filteredSearch.updateObject(mergeUrlParams({ page }, this.appliedFilters));
      this.setCurrentPage(page);
      scrollToElement('#content-body');
    },
    loadIssues() {
      if (!this.isInDashboardPage) {
        this.isLoadingDisabled = false;
      } else {
        const [authorUsername] = getParameterValues('author_username');
        this.isLoadingDisabled = authorUsername !== gon.current_username;
      }

      if (!this.isLoadingDisabled) {
        this.fetchIssues(this.endpoint);
      }
    },
    applyLabelFilter(label) {
      this.filteredSearch.clearSearch();
      this.filteredSearch.updateObject(
        `?${objectToQueryString({ 'label_name[]': encodeURIComponent(label) })}`,
      );
      this.filteredSearch.loadSearchParamsFromURL();
    },
  },
};
</script>
<template>
  <div v-if="hasIssues">
    <ul class="content-list issues-list issuable-list">
      <issue
        v-for="issue in issues"
        :key="issue.id"
        :issue="issue"
        :is-bulk-updating="isBulkUpdating"
        :can-bulk-update="canBulkUpdate"
        @issueLabelClicked="applyLabelFilter"
      />
    </ul>
    <div class="gl-pagination prepend-top-default">
      <gl-pagination
        :change="updatePage"
        :page="currentPage"
        :per-page="ISSUES_PER_PAGE"
        :total-items="totalItems"
        :next-text="__('Next')"
        :prev-text="__('Prev')"
        class="justify-content-center"
      />
    </div>
  </div>
  <IssuesLoadingState v-else-if="loading" />
  <issues-empty-state
    v-else
    :state="getCurrentState()"
    :button-path="createPath"
    :has-filters="hasFilters"
    :loading-disabled="isLoadingDisabled"
  />
</template>
