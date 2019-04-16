import $ from 'jquery';
import axios from '~/lib/utils/axios_utils';
import * as types from './mutation_types';
import { parseIntPagination, normalizeHeaders } from '~/lib/utils/common_utils';
import { s__ } from '~/locale';
import createFlash from '~/flash';

export default {
  setVulnerabilitiesEndpoint: ({ commit }, endpoint) => {
    commit(types.SET_VULNERABILITIES_ENDPOINT, endpoint);
  },

  setVulnerabilitiesCountEndpoint: ({ commit }, endpoint) => {
    commit(types.SET_VULNERABILITIES_COUNT_ENDPOINT, endpoint);
  },

  fetchVulnerabilitiesCount: ({ state, dispatch }, params = {}) => {
    if (!state.vulnerabilitiesCountEndpoint) {
      return;
    }
    dispatch('requestVulnerabilitiesCount');

    axios({
      method: 'GET',
      url: state.vulnerabilitiesCountEndpoint,
      params,
    })
      .then(response => {
        const { data } = response;
        dispatch('receiveVulnerabilitiesCountSuccess', { data });
      })
      .catch(() => {
        dispatch('receiveVulnerabilitiesCountError');
      });
  },

  requestVulnerabilitiesCount: ({ commit }) => {
    commit(types.REQUEST_VULNERABILITIES_COUNT);
  },

  receiveVulnerabilitiesCountSuccess: ({ commit }, { data }) => {
    commit(types.RECEIVE_VULNERABILITIES_COUNT_SUCCESS, data);
  },

  receiveVulnerabilitiesCountError: ({ commit }) => {
    commit(types.RECEIVE_VULNERABILITIES_COUNT_ERROR);
  },

  setVulnerabilitiesPage: ({ commit }, page) => {
    commit(types.SET_VULNERABILITIES_PAGE, page);
  },

  fetchVulnerabilities: ({ state, dispatch }, params = {}) => {
    if (!state.vulnerabilitiesEndpoint) {
      return;
    }
    dispatch('requestVulnerabilities');

    axios({
      method: 'GET',
      url: state.vulnerabilitiesEndpoint,
      params,
    })
      .then(response => {
        const { headers, data } = response;
        dispatch('receiveVulnerabilitiesSuccess', { headers, data });
      })
      .catch(() => {
        dispatch('receiveVulnerabilitiesError');
      });
  },

  requestVulnerabilities: ({ commit }) => {
    commit(types.REQUEST_VULNERABILITIES);
  },

  receiveVulnerabilitiesSuccess: ({ commit }, { headers, data }) => {
    const normalizedHeaders = normalizeHeaders(headers);
    const pageInfo = parseIntPagination(normalizedHeaders);
    const vulnerabilities = data;

    commit(types.RECEIVE_VULNERABILITIES_SUCCESS, { pageInfo, vulnerabilities });
  },

  receiveVulnerabilitiesError: ({ commit }) => {
    commit(types.RECEIVE_VULNERABILITIES_ERROR);
  },

  openModal: ({ commit }, payload = {}) => {
    $('#modal-mrwidget-security-issue').modal('show');

    commit(types.SET_MODAL_DATA, payload);
  },

  createIssue: ({ dispatch }, { vulnerability, flashError }) => {
    dispatch('requestCreateIssue');
    axios
      .post(vulnerability.vulnerability_feedback_issue_path, {
        vulnerability_feedback: {
          feedback_type: 'issue',
          category: vulnerability.report_type,
          project_fingerprint: vulnerability.project_fingerprint,
          vulnerability_data: {
            ...vulnerability,
            category: vulnerability.report_type,
          },
        },
      })
      .then(({ data }) => {
        dispatch('receiveCreateIssueSuccess', data);
      })
      .catch(() => {
        dispatch('receiveCreateIssueError', { flashError });
      });
  },

  requestCreateIssue: ({ commit }) => {
    commit(types.REQUEST_CREATE_ISSUE);
  },

  receiveCreateIssueSuccess: ({ commit }, payload) => {
    commit(types.RECEIVE_CREATE_ISSUE_SUCCESS, payload);
  },

  receiveCreateIssueError: ({ commit }, { flashError }) => {
    commit(types.RECEIVE_CREATE_ISSUE_ERROR);

    if (flashError) {
      createFlash(
        s__('Security Reports|There was an error creating the issue.'),
        'alert',
        document.querySelector('.ci-table'),
      );
    }
  },

  dismissVulnerability: ({ dispatch }, { vulnerability, flashError }) => {
    dispatch('requestDismissVulnerability');

    axios
      .post(vulnerability.vulnerability_feedback_dismissal_path, {
        vulnerability_feedback: {
          feedback_type: 'dismissal',
          category: vulnerability.report_type,
          project_fingerprint: vulnerability.project_fingerprint,
          vulnerability_data: {
            ...vulnerability,
            category: vulnerability.report_type,
          },
        },
      })
      .then(({ data }) => {
        const { id } = vulnerability;
        dispatch('receiveDismissVulnerabilitySuccess', { id, data });
      })
      .catch(() => {
        dispatch('receiveDismissVulnerabilityError', { flashError });
      });
  },

  requestDismissVulnerability: ({ commit }) => {
    commit(types.REQUEST_DISMISS_VULNERABILITY);
  },

  receiveDismissVulnerabilitySuccess: ({ commit }, payload) => {
    commit(types.RECEIVE_DISMISS_VULNERABILITY_SUCCESS, payload);
  },

  receiveDismissVulnerabilityError: ({ commit }, { flashError }) => {
    commit(types.RECEIVE_DISMISS_VULNERABILITY_ERROR);
    if (flashError) {
      createFlash(
        s__('Security Reports|There was an error dismissing the vulnerability.'),
        'alert',
        document.querySelector('.ci-table'),
      );
    }
  },

  undoDismiss: ({ dispatch }, { vulnerability, flashError }) => {
    const { vulnerability_feedback_dismissal_path, dismissal_feedback } = vulnerability;
    // eslint-disable-next-line camelcase
    const url = `${vulnerability_feedback_dismissal_path}/${dismissal_feedback.id}`;

    dispatch('requestUndoDismiss');

    axios
      .delete(url)
      .then(() => {
        const { id } = vulnerability;
        dispatch('receiveUndoDismissSuccess', { id });
      })
      .catch(() => {
        dispatch('receiveUndoDismissError', { flashError });
      });
  },

  requestUndoDismiss: ({ commit }) => {
    commit(types.REQUEST_REVERT_DISMISSAL);
  },

  receiveUndoDismissSuccess: ({ commit }, payload) => {
    commit(types.RECEIVE_REVERT_DISMISSAL_SUCCESS, payload);
  },

  receiveUndoDismissError: ({ commit }, { flashError }) => {
    commit(types.RECEIVE_REVERT_DISMISSAL_ERROR);
    if (flashError) {
      createFlash(
        s__('Security Reports|There was an error reverting this dismissal.'),
        'alert',
        document.querySelector('.ci-table'),
      );
    }
  },

  createMergeRequest: ({ dispatch }, { vulnerability, flashError }) => {
    const {
      report_type,
      project_fingerprint,
      vulnerability_feedback_merge_request_path,
    } = vulnerability;

    dispatch('requestCreateMergeRequest');

    axios
      .post(vulnerability_feedback_merge_request_path, {
        vulnerability_feedback: {
          feedback_type: 'merge_request',
          category: report_type,
          project_fingerprint,
          vulnerability_data: {
            ...vulnerability,
            category: report_type,
          },
        },
      })
      .then(({ data }) => {
        dispatch('receiveCreateMergeRequestSuccess', data);
      })
      .catch(() => {
        dispatch('receiveCreateMergeRequestError', { flashError });
      });
  },

  requestCreateMergeRequest: ({ commit }) => {
    commit(types.REQUEST_CREATE_MERGE_REQUEST);
  },

  receiveCreateMergeRequestSuccess: ({ commit }, payload) => {
    commit(types.RECEIVE_CREATE_MERGE_REQUEST_SUCCESS, payload);
  },

  receiveCreateMergeRequestError: ({ commit }, { flashError }) => {
    commit(types.RECEIVE_CREATE_MERGE_REQUEST_ERROR);

    if (flashError) {
      createFlash(
        s__('Security Reports|There was an error creating the merge request.'),
        'alert',
        document.querySelector('.ci-table'),
      );
    }
  },

  setVulnerabilitiesHistoryEndpoint: ({ commit }, endpoint) => {
    commit(types.SET_VULNERABILITIES_HISTORY_ENDPOINT, endpoint);
  },

  fetchVulnerabilitiesHistory: ({ state, dispatch }, params = {}) => {
    if (!state.vulnerabilitiesHistoryEndpoint) {
      return;
    }
    dispatch('requestVulnerabilitiesHistory');

    axios({
      method: 'GET',
      url: state.vulnerabilitiesHistoryEndpoint,
      params,
    })
      .then(response => {
        const { data } = response;
        dispatch('receiveVulnerabilitiesHistorySuccess', { data });
      })
      .catch(() => {
        dispatch('receiveVulnerabilitiesHistoryError');
      });
  },

  setVulnerabilitiesHistoryDayRange: ({ commit }, days) => {
    commit(types.SET_VULNERABILITIES_HISTORY_DAY_RANGE, days);
  },

  requestVulnerabilitiesHistory: ({ commit }) => {
    commit(types.REQUEST_VULNERABILITIES_HISTORY);
  },

  receiveVulnerabilitiesHistorySuccess: ({ commit }, { data }) => {
    commit(types.RECEIVE_VULNERABILITIES_HISTORY_SUCCESS, data);
  },

  receiveVulnerabilitiesHistoryError: ({ commit }) => {
    commit(types.RECEIVE_VULNERABILITIES_HISTORY_ERROR);
  },
};
