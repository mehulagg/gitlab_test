import { visitUrl } from '~/lib/utils/url_utility';
import * as types from './mutation_types';
import { DAYS } from './constants';
import { isSameVulnerability } from './utils';

export default {
  [types.SET_PIPELINE_ID](state, payload) {
    state.pipelineId = payload;
  },
  [types.SET_VULNERABILITIES_ENDPOINT](state, payload) {
    state.vulnerabilitiesEndpoint = payload;
  },
  [types.REQUEST_VULNERABILITIES](state) {
    state.isLoadingVulnerabilities = true;
    state.errorLoadingVulnerabilities = false;
  },
  [types.RECEIVE_VULNERABILITIES_SUCCESS](state, payload) {
    state.isLoadingVulnerabilities = false;
    state.pageInfo = payload.pageInfo;
    state.vulnerabilities = payload.vulnerabilities;
  },
  [types.RECEIVE_VULNERABILITIES_ERROR](state) {
    state.isLoadingVulnerabilities = false;
    state.errorLoadingVulnerabilities = true;
  },
  [types.SET_VULNERABILITIES_COUNT_ENDPOINT](state, payload) {
    state.vulnerabilitiesCountEndpoint = payload;
  },
  [types.SET_VULNERABILITIES_PAGE](state, payload) {
    state.pageInfo = { ...state.pageInfo, page: payload };
  },
  [types.REQUEST_VULNERABILITIES_COUNT](state) {
    state.isLoadingVulnerabilitiesCount = true;
    state.errorLoadingVulnerabilitiesCount = false;
  },
  [types.RECEIVE_VULNERABILITIES_COUNT_SUCCESS](state, payload) {
    state.isLoadingVulnerabilitiesCount = false;
    state.vulnerabilitiesCount = payload;
  },
  [types.RECEIVE_VULNERABILITIES_COUNT_ERROR](state) {
    state.isLoadingVulnerabilitiesCount = false;
    state.errorLoadingVulnerabilitiesCount = true;
  },
  [types.SET_VULNERABILITIES_HISTORY_ENDPOINT](state, payload) {
    state.vulnerabilitiesHistoryEndpoint = payload;
  },
  [types.SET_VULNERABILITIES_HISTORY_DAY_RANGE](state, days) {
    state.vulnerabilitiesHistoryDayRange = days;

    if (days <= DAYS.THIRTY) {
      state.vulnerabilitiesHistoryMaxDayInterval = 7;
    } else if (days > DAYS.SIXTY) {
      state.vulnerabilitiesHistoryMaxDayInterval = 14;
    }
  },
  [types.REQUEST_VULNERABILITIES_HISTORY](state) {
    state.isLoadingVulnerabilitiesHistory = true;
    state.errorLoadingVulnerabilitiesHistory = false;
  },
  [types.RECEIVE_VULNERABILITIES_HISTORY_SUCCESS](state, payload) {
    state.isLoadingVulnerabilitiesHistory = false;
    state.vulnerabilitiesHistory = payload;
  },
  [types.RECEIVE_VULNERABILITIES_HISTORY_ERROR](state) {
    state.isLoadingVulnerabilitiesHistory = false;
    state.errorLoadingVulnerabilitiesHistory = true;
  },
  [types.REQUEST_CREATE_ISSUE](state) {
    state.isCreatingIssue = true;
  },
  [types.RECEIVE_CREATE_ISSUE_SUCCESS](state, payload) {
    // We don't cancel the loading state here because we're navigating away from the page
    visitUrl(payload.issue_url);
  },
  [types.RECEIVE_CREATE_ISSUE_ERROR](state) {
    state.isCreatingIssue = false;
  },
  [types.REQUEST_DISMISS_VULNERABILITY](state) {
    state.isDismissingVulnerability = true;
  },
  [types.RECEIVE_DISMISS_VULNERABILITY_SUCCESS](state, payload) {
    const vulnerability = state.vulnerabilities.find(vuln =>
      isSameVulnerability(vuln, payload.vulnerability),
    );
    vulnerability.dismissal_feedback = payload.data;
    state.isDismissingVulnerability = false;
  },
  [types.RECEIVE_DISMISS_VULNERABILITY_ERROR](state) {
    state.isDismissingVulnerability = false;
  },
  [types.REQUEST_ADD_DISMISSAL_COMMENT](state) {
    state.isDismissingVulnerability = true;
  },
  [types.RECEIVE_ADD_DISMISSAL_COMMENT_SUCCESS](state, payload) {
    const vulnerability = state.vulnerabilities.find(vuln =>
      isSameVulnerability(vuln, payload.vulnerability),
    );
    if (vulnerability) {
      vulnerability.dismissal_feedback = payload.data;
      state.isDismissingVulnerability = false;
    }
    vulnerability.dismissal_feedback = payload.data;
    state.isDismissingVulnerability = false;
  },
  [types.RECEIVE_ADD_DISMISSAL_COMMENT_ERROR](state) {
    state.isDismissingVulnerability = false;
  },
  [types.REQUEST_DELETE_DISMISSAL_COMMENT](state) {
    state.isDismissingVulnerability = true;
  },
  [types.RECEIVE_DELETE_DISMISSAL_COMMENT_SUCCESS](state, payload) {
    const vulnerability = state.vulnerabilities.find(vuln => vuln.id === payload.id);
    if (vulnerability) {
      vulnerability.dismissal_feedback = payload.data;
      state.isDismissingVulnerability = false;
    }
  },
  [types.RECEIVE_DELETE_DISMISSAL_COMMENT_ERROR](state) {
    state.isDismissingVulnerability = false;
  },
  [types.REQUEST_REVERT_DISMISSAL](state) {
    state.isDismissingVulnerability = true;
  },
  [types.RECEIVE_REVERT_DISMISSAL_SUCCESS](state, payload) {
    const vulnerability = state.vulnerabilities.find(vuln =>
      isSameVulnerability(vuln, payload.vulnerability),
    );
    vulnerability.dismissal_feedback = null;
    vulnerability.dismissalFeedback = null;
    state.isDismissingVulnerability = false;
  },
  [types.RECEIVE_REVERT_DISMISSAL_ERROR](state) {
    state.isDismissingVulnerability = false;
  },
  [types.REQUEST_CREATE_MERGE_REQUEST](state) {
    state.isCreatingMergeRequest = true;
  },
  [types.RECEIVE_CREATE_MERGE_REQUEST_SUCCESS](state, payload) {
    // We don't cancel the loading state here because we're navigating away from the page
    visitUrl(payload.merge_request_path);
  },
  [types.RECEIVE_CREATE_MERGE_REQUEST_ERROR](state) {
    state.isCreatingIssue = false;
  },
};
