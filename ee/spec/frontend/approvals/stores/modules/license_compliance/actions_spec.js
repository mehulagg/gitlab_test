import MockAdapter from 'axios-mock-adapter';
import testAction from 'helpers/vuex_action_helper';
import * as actions from 'ee/approvals/stores/modules/license_compliance/actions';
import * as baseMutationTypes from 'ee/approvals/stores/modules/base/mutation_types';
import { mapApprovalSettingsResponse } from 'ee/approvals/mappers';
import axios from '~/lib/utils/axios_utils';

describe('EE approvals license-compliance actions', () => {
  let state;
  let axiosMock;

  const mocks = {
    state: {
      settingsPath: 'projects/9/approval_settings',
    },
  };

  beforeEach(() => {
    state = {
      settings: {
        settingsPath: mocks.state.settingsPath,
      },
    };
    axiosMock = new MockAdapter(axios);
  });

  describe('receiveRulesSuccess', () => {
    it('sets rules to given payload and loading to false', () => {
      const payload = {};

      return testAction(actions.receiveRulesSuccess, payload, state, [
        {
          type: baseMutationTypes.SET_APPROVAL_SETTINGS,
          payload,
        },
        {
          type: baseMutationTypes.SET_LOADING,
          payload: false,
        },
      ]);
    });
  });

  describe('fetchRules', () => {
    it('sets loading state to be true and dispatches "receiveRuleSuccess"', () => {
      const responseData = { rules: [] };
      axiosMock.onGet(mocks.state.settingsPath).replyOnce(200, responseData);

      return testAction(
        actions.fetchRules,
        null,
        state,
        [
          {
            type: baseMutationTypes.SET_LOADING,
            payload: true,
          },
        ],
        [
          {
            type: 'receiveRulesSuccess',
            payload: mapApprovalSettingsResponse(responseData),
          },
        ],
      );
    });
  });

  describe('postRule', () => {
    it('is a placeholder', () => {
      expect(true).toBe(true);
    });
  });

  describe('deleteRule', () => {
    it('is a placeholder', () => {
      expect(true).toBe(true);
    });
  });

  describe('putRule', () => {
    it('is a placeholder', () => {
      expect(true).toBe(true);
    });
  });

  describe('putFallbackRule', () => {
    it('is a placeholder', () => {
      expect(true).toBe(true);
    });
  });
});
