import axios from 'axios';
import MockAdapter from 'axios-mock-adapter';
import testAction from 'helpers/vuex_action_helper';
import * as actions from 'ee/approvals/stores/modules/license_compliance/actions';
import * as baseMutationTypes from 'ee/approvals/stores/modules/base/mutation_types';
import createBaseState from 'ee/approvals/stores/modules/base/state';

describe('EE approvals license-compliance actions', () => {
  let state;
  let axiosMock;

  beforeEach(() => {
    state = createBaseState();
    axiosMock = new MockAdapter(axios);
  });

  describe('receiveRulesSuccess', () => {
    it('sets rules to given payload and loading to false', () => {
      const approvalSetting = {};
      testAction(actions.receiveRulesSuccess, approvalSetting, state, [
        {
          type: baseMutationTypes.SET_APPROVAL_SETTINGS,
          payload: approvalSetting,
        },
        {
          type: baseMutationTypes.SET_LOADING,
          payload: false,
        },
      ]);
    });
  });

  describe('fetchRules', () => {});
});
