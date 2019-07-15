import createState from 'ee/security_dashboard/store/modules/vulnerabilities/state';
import * as types from 'ee/security_dashboard/store/modules/vulnerabilities/mutation_types';
import mutations from 'ee/security_dashboard/store/modules/vulnerabilities/mutations';
import { DAYS } from 'ee/security_dashboard/store/modules/vulnerabilities/constants';
import mockData from './data/mock_data_vulnerabilities.json';

describe('vulnerabilities module mutations', () => {
  let state;

  beforeEach(() => {
    state = createState();
  });

  describe('SET_PIPELINE_ID', () => {
    const pipelineId = 123;

    it(`should set the pipelineId to ${pipelineId}`, () => {
      mutations[types.SET_PIPELINE_ID](state, pipelineId);

      expect(state.pipelineId).toBe(pipelineId);
    });
  });

  describe('SET_VULNERABILITIES_ENDPOINT', () => {
    it('should set `vulnerabilitiesEndpoint` to `fakepath.json`', () => {
      const endpoint = 'fakepath.json';

      mutations[types.SET_VULNERABILITIES_ENDPOINT](state, endpoint);

      expect(state.vulnerabilitiesEndpoint).toEqual(endpoint);
    });
  });

  describe('SET_VULNERABILITIES_PAGE', () => {
    const page = 3;
    it(`should set pageInfo.page to ${page}`, () => {
      mutations[types.SET_VULNERABILITIES_PAGE](state, page);

      expect(state.pageInfo.page).toEqual(page);
    });
  });

  describe('REQUEST_VULNERABILITIES', () => {
    beforeEach(() => {
      state.errorLoadingVulnerabilities = true;
      mutations[types.REQUEST_VULNERABILITIES](state);
    });

    it('should set `isLoadingVulnerabilities` to `true`', () => {
      expect(state.isLoadingVulnerabilities).toBeTruthy();
    });

    it('should set `errorLoadingVulnerabilities` to `false`', () => {
      expect(state.errorLoadingVulnerabilities).toBeFalsy();
    });
  });

  describe('RECEIVE_VULNERABILITIES_SUCCESS', () => {
    let payload;

    beforeEach(() => {
      payload = {
        vulnerabilities: mockData,
        pageInfo: { a: 1, b: 2, c: 3 },
      };
      mutations[types.RECEIVE_VULNERABILITIES_SUCCESS](state, payload);
    });

    it('should set `isLoadingVulnerabilities` to `false`', () => {
      expect(state.isLoadingVulnerabilities).toBeFalsy();
    });

    it('should set `pageInfo`', () => {
      expect(state.pageInfo).toBe(payload.pageInfo);
    });

    it('should set `vulnerabilities`', () => {
      expect(state.vulnerabilities).toBe(payload.vulnerabilities);
    });
  });

  describe('RECEIVE_VULNERABILITIES_ERROR', () => {
    it('should set `isLoadingVulnerabilities` to `false`', () => {
      mutations[types.RECEIVE_VULNERABILITIES_ERROR](state);

      expect(state.isLoadingVulnerabilities).toBeFalsy();
    });
  });

  describe('SET_VULNERABILITIES_COUNT_ENDPOINT', () => {
    it('should set `vulnerabilitiesCountEndpoint` to `fakepath.json`', () => {
      const endpoint = 'fakepath.json';

      mutations[types.SET_VULNERABILITIES_COUNT_ENDPOINT](state, endpoint);

      expect(state.vulnerabilitiesCountEndpoint).toEqual(endpoint);
    });
  });

  describe('REQUEST_VULNERABILITIES_COUNT', () => {
    beforeEach(() => {
      state.errorLoadingVulnerabilitiesCount = true;
      mutations[types.REQUEST_VULNERABILITIES_COUNT](state);
    });

    it('should set `isLoadingVulnerabilitiesCount` to `true`', () => {
      expect(state.isLoadingVulnerabilitiesCount).toBeTruthy();
    });

    it('should set `errorLoadingVulnerabilitiesCount` to `false`', () => {
      expect(state.errorLoadingVulnerabilitiesCount).toBeFalsy();
    });
  });

  describe('RECEIVE_VULNERABILITIES_COUNT_SUCCESS', () => {
    let payload;

    beforeEach(() => {
      payload = mockData;
      mutations[types.RECEIVE_VULNERABILITIES_COUNT_SUCCESS](state, payload);
    });

    it('should set `isLoadingVulnerabilitiesCount` to `false`', () => {
      expect(state.isLoadingVulnerabilitiesCount).toBeFalsy();
    });

    it('should set `vulnerabilitiesCount`', () => {
      expect(state.vulnerabilitiesCount).toBe(payload);
    });
  });

  describe('RECEIVE_VULNERABILITIES_COUNT_ERROR', () => {
    it('should set `isLoadingVulnerabilitiesCount` to `false`', () => {
      mutations[types.RECEIVE_VULNERABILITIES_COUNT_ERROR](state);

      expect(state.isLoadingVulnerabilitiesCount).toBeFalsy();
    });
  });

  describe('SET_VULNERABILITIES_HISTORY_ENDPOINT', () => {
    it('should set `vulnerabilitiesHistoryEndpoint` to `fakepath.json`', () => {
      const endpoint = 'fakepath.json';

      mutations[types.SET_VULNERABILITIES_HISTORY_ENDPOINT](state, endpoint);

      expect(state.vulnerabilitiesHistoryEndpoint).toEqual(endpoint);
    });
  });

  describe('REQUEST_VULNERABILITIES_HISTORY', () => {
    beforeEach(() => {
      state.errorLoadingVulnerabilitiesHistory = true;
      mutations[types.REQUEST_VULNERABILITIES_HISTORY](state);
    });

    it('should set `isLoadingVulnerabilitiesHistory` to `true`', () => {
      expect(state.isLoadingVulnerabilitiesHistory).toBeTruthy();
    });

    it('should set `errorLoadingVulnerabilitiesHistory` to `false`', () => {
      expect(state.errorLoadingVulnerabilitiesHistory).toBeFalsy();
    });
  });

  describe('RECEIVE_VULNERABILITIES_HISTORY_SUCCESS', () => {
    let payload;

    beforeEach(() => {
      payload = mockData;
      mutations[types.RECEIVE_VULNERABILITIES_HISTORY_SUCCESS](state, payload);
    });

    it('should set `isLoadingVulnerabilitiesHistory` to `false`', () => {
      expect(state.isLoadingVulnerabilitiesHistory).toBeFalsy();
    });

    it('should set `vulnerabilitiesHistory`', () => {
      expect(state.vulnerabilitiesHistory).toBe(payload);
    });
  });

  describe('RECEIVE_VULNERABILITIES_HISTORY_ERROR', () => {
    it('should set `isLoadingVulnerabilitiesHistory` to `false`', () => {
      mutations[types.RECEIVE_VULNERABILITIES_HISTORY_ERROR](state);

      expect(state.isLoadingVulnerabilitiesHistory).toBeFalsy();
    });
  });

  describe('SET_VULNERABILITIES_HISTORY_DAY_RANGE', () => {
    it('should set the vulnerabilitiesHistoryDayRange to number of days', () => {
      mutations[types.SET_VULNERABILITIES_HISTORY_DAY_RANGE](state, DAYS.THIRTY);

      expect(state.vulnerabilitiesHistoryDayRange).toEqual(DAYS.THIRTY);
    });

    it('should set the vulnerabilitiesHistoryMaxDayInterval to 7 if days are 60 and under', () => {
      mutations[types.SET_VULNERABILITIES_HISTORY_DAY_RANGE](state, DAYS.THIRTY);

      expect(state.vulnerabilitiesHistoryMaxDayInterval).toEqual(7);
    });

    it('should set the vulnerabilitiesHistoryMaxDayInterval to 14 if over 60', () => {
      mutations[types.SET_VULNERABILITIES_HISTORY_DAY_RANGE](state, DAYS.NINETY);

      expect(state.vulnerabilitiesHistoryMaxDayInterval).toEqual(14);
    });
  });

  describe('REQUEST_CREATE_ISSUE', () => {
    beforeEach(() => {
      mutations[types.REQUEST_CREATE_ISSUE](state);
    });

    it('should set isCreatingIssue to true', () => {
      expect(state.isCreatingIssue).toBe(true);
    });
  });

  describe('RECEIVE_CREATE_ISSUE_SUCCESS', () => {
    it('should fire the visitUrl function on the issue URL', () => {
      const payload = { issue_url: 'fakepath.html' };
      const visitUrl = spyOnDependency(mutations, 'visitUrl');
      mutations[types.RECEIVE_CREATE_ISSUE_SUCCESS](state, payload);

      expect(visitUrl).toHaveBeenCalledWith(payload.issue_url);
    });
  });

  describe('RECEIVE_CREATE_ISSUE_ERROR', () => {
    beforeEach(() => {
      mutations[types.RECEIVE_CREATE_ISSUE_ERROR](state);
    });

    it('should set isCreatingIssue to false', () => {
      expect(state.isCreatingIssue).toBe(false);
    });
  });

  describe('REQUEST_CREATE_MERGE_REQUEST', () => {
    beforeEach(() => {
      mutations[types.REQUEST_CREATE_MERGE_REQUEST](state);
    });

    it('should set isCreatingMergeRequest to true', () => {
      expect(state.isCreatingMergeRequest).toBe(true);
    });
  });

  describe('RECEIVE_CREATE_MERGE_REQUEST_SUCCESS', () => {
    it('should fire the visitUrl function on the merge request URL', () => {
      const payload = { merge_request_path: 'fakepath.html' };
      const visitUrl = spyOnDependency(mutations, 'visitUrl');
      mutations[types.RECEIVE_CREATE_MERGE_REQUEST_SUCCESS](state, payload);

      expect(visitUrl).toHaveBeenCalledWith(payload.merge_request_path);
    });
  });

  describe('RECEIVE_CREATE_MERGE_REQUEST_ERROR', () => {
    beforeEach(() => {
      mutations[types.RECEIVE_CREATE_MERGE_REQUEST_ERROR](state);
    });

    it('should set isCreatingMergeRequest to false', () => {
      expect(state.isCreatingMergeRequest).toBe(false);
    });
  });

  describe('REQUEST_DISMISS_VULNERABILITY', () => {
    beforeEach(() => {
      mutations[types.REQUEST_DISMISS_VULNERABILITY](state);
    });

    it('should set isDismissingVulnerability to true', () => {
      expect(state.isDismissingVulnerability).toBe(true);
    });
  });

  describe('RECEIVE_DISMISS_VULNERABILITY_SUCCESS', () => {
    let payload;
    let vulnerability;
    let data;

    beforeEach(() => {
      state.vulnerabilities = mockData;
      [vulnerability] = mockData;
      data = { name: 'dismissal feedback' };
      payload = { vulnerability, data };
      mutations[types.RECEIVE_DISMISS_VULNERABILITY_SUCCESS](state, payload);
    });

    it('should set the dismissal feedback on the passed vulnerability', () => {
      expect(vulnerability.dismissal_feedback).toEqual(data);
    });

    it('should set isDismissingVulnerability to false', () => {
      expect(state.isDismissingVulnerability).toBe(false);
    });
  });

  describe('RECEIVE_DISMISS_VULNERABILITY_ERROR', () => {
    beforeEach(() => {
      mutations[types.RECEIVE_DISMISS_VULNERABILITY_ERROR](state);
    });

    it('should set isDismissingVulnerability to false', () => {
      expect(state.isDismissingVulnerability).toBe(false);
    });
  });

  describe('REQUEST_DELETE_DISMISSAL_COMMENT', () => {
    beforeEach(() => {
      mutations[types.REQUEST_DELETE_DISMISSAL_COMMENT](state);
    });

    it('should set isDismissingVulnerability to true', () => {
      expect(state.isDismissingVulnerability).toBe(true);
    });
  });

  describe('RECEIVE_DELETE_DISMISSAL_COMMENT_SUCCESS', () => {
    let payload;
    let vulnerability;
    let data;

    beforeEach(() => {
      state.vulnerabilities = mockData;
      [vulnerability] = mockData;
      data = { name: '' };
      payload = { id: vulnerability.id, data };
      mutations[types.RECEIVE_DELETE_DISMISSAL_COMMENT_SUCCESS](state, payload);
    });

    it('should set the dismissal feedback on the passed vulnerability to an empty string', () => {
      expect(state.vulnerabilities[0].dismissal_feedback).toEqual({ name: '' });
    });

    it('should set isDismissingVulnerability to false', () => {
      expect(state.isDismissingVulnerability).toBe(false);
    });
  });

  describe('RECEIVE_DELETE_DISMISSAL_COMMENT_ERROR', () => {
    beforeEach(() => {
      mutations[types.RECEIVE_DELETE_DISMISSAL_COMMENT_ERROR](state);
    });

    it('should set isDismissingVulnerability to false', () => {
      expect(state.isDismissingVulnerability).toBe(false);
    });
  });

  describe(types.HIDE_DISMISSAL_DELETE_BUTTONS, () => {
    beforeEach(() => {
      mutations[types.HIDE_DISMISSAL_DELETE_BUTTONS](state);
    });
  });

  describe('REQUEST_ADD_DISMISSAL_COMMENT', () => {
    beforeEach(() => {
      mutations[types.REQUEST_ADD_DISMISSAL_COMMENT](state);
    });

    it('should set isDismissingVulnerability to true', () => {
      expect(state.isDismissingVulnerability).toBe(true);
    });
  });

  describe('RECEIVE_ADD_DISMISSAL_COMMENT_SUCCESS', () => {
    let payload;
    let vulnerability;
    let data;

    beforeEach(() => {
      state.vulnerabilities = mockData;
      [vulnerability] = mockData;
      data = { name: 'dismissal feedback' };
      payload = { vulnerability, data };
      mutations[types.RECEIVE_ADD_DISMISSAL_COMMENT_SUCCESS](state, payload);
    });

    it('should set the dismissal feedback on the passed vulnerability', () => {
      expect(state.vulnerabilities[0].dismissal_feedback).toEqual(data);
    });

    it('should set isDismissingVulnerability to false', () => {
      expect(state.isDismissingVulnerability).toBe(false);
    });
  });

  describe('RECEIVE_ADD_DISMISSAL_COMMENT_ERROR', () => {
    beforeEach(() => {
      mutations[types.RECEIVE_ADD_DISMISSAL_COMMENT_ERROR](state);
    });

    it('should set isDismissingVulnerability to false', () => {
      expect(state.isDismissingVulnerability).toBe(false);
    });
  });

  describe('REQUEST_REVERT_DISMISSAL', () => {
    beforeEach(() => {
      mutations[types.REQUEST_REVERT_DISMISSAL](state);
    });

    it('should set isDismissingVulnerability to true', () => {
      expect(state.isDismissingVulnerability).toBe(true);
    });
  });

  describe('RECEIVE_REVERT_DISMISSAL_SUCCESS', () => {
    let payload;
    let vulnerability;

    beforeEach(() => {
      state.vulnerabilities = mockData;
      [vulnerability] = mockData;
      payload = { vulnerability };
      mutations[types.RECEIVE_REVERT_DISMISSAL_SUCCESS](state, payload);
    });

    it('should set the dismissal feedback on the passed vulnerability', () => {
      expect(vulnerability.dismissal_feedback).toBeNull();
    });

    it('should set isDismissingVulnerability to false', () => {
      expect(state.isDismissingVulnerability).toBe(false);
    });
  });

  describe('RECEIVE_REVERT_DISMISSAL_ERROR', () => {
    beforeEach(() => {
      mutations[types.RECEIVE_REVERT_DISMISSAL_ERROR](state);
    });

    it('should set isDismissingVulnerability to false', () => {
      expect(state.isDismissingVulnerability).toBe(false);
    });
  });
});
