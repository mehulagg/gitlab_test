import createFlash from '~/flash';
import { __ } from '~/locale';
import axios from '~/lib/utils/axios_utils';
import * as types from '../base/mutation_types';
import {
  mapApprovalRuleRequest,
  mapApprovalSettingsResponse,
  mapApprovalFallbackRuleRequest,
} from '../../../mappers';

export default {
  requestRules: ({ commit }) => {
    commit(types.SET_LOADING, true);
  },

  receiveRulesSuccess: ({ commit }, approvalSettings) => {
    commit(types.SET_APPROVAL_SETTINGS, approvalSettings);
    commit(types.SET_LOADING, false);
  },

  receiveRulesError: () => {
    createFlash(__('An error occurred fetching the approval rules.'));
  },

  fetchRules: ({ rootState, dispatch }) => {
    const { settingsPath } = rootState.settings;

    dispatch('requestRules');

    return axios
      .get(settingsPath)
      .then(response => dispatch('receiveRulesSuccess', mapApprovalSettingsResponse(response.data)))
      .catch(() => dispatch('receiveRulesError'));
  },

  postRuleSuccess: ({ dispatch }) => {
    dispatch('createModal/close');
    dispatch('fetchRules');
  },

  postRuleError: () => {
    createFlash(__('An error occurred while updating approvers'));
  },

  postRule: ({ rootState, dispatch }, rule) => {
    const { rulesPath } = rootState.settings;

    return axios
      .post(rulesPath, mapApprovalRuleRequest(rule))
      .then(() => dispatch('postRuleSuccess'))
      .catch(() => dispatch('postRuleError'));
  },

  putRule: ({ rootState, dispatch }, { id, ...newRule }) => {
    const { rulesPath } = rootState.settings;

    return axios
      .put(`${rulesPath}/${id}`, mapApprovalRuleRequest(newRule))
      .then(() => dispatch('postRuleSuccess'))
      .catch(() => dispatch('postRuleError'));
  },

  deleteRuleSuccess: ({ dispatch }) => {
    dispatch('deleteModal/close');
    dispatch('fetchRules');
  },

  deleteRuleError: () => {
    createFlash(__('An error occurred while deleting the approvers group'));
  },

  deleteRule: ({ rootState, dispatch }, id) => {
    const { rulesPath } = rootState.settings;

    return axios
      .delete(`${rulesPath}/${id}`)
      .then(() => dispatch('deleteRuleSuccess'))
      .catch(() => dispatch('deleteRuleError'));
  },

  putFallbackRuleSuccess: ({ dispatch }) => {
    dispatch('createModal/close');
    dispatch('fetchRules');
  },

  putFallbackRuleError: () => {
    createFlash(__('An error occurred while saving the approval settings'));
  },

  putFallbackRule: ({ rootState, dispatch }, fallback) => {
    const { projectPath } = rootState.settings;

    return axios
      .put(projectPath, mapApprovalFallbackRuleRequest(fallback))
      .then(() => dispatch('putFallbackRuleSuccess'))
      .catch(() => dispatch('putFallbackRuleError'));
  },

  requestEditRule: ({ dispatch }, rule) => {
    dispatch('createModal/open', rule);
  },

  requestDeleteRule: ({ dispatch }, rule) => {
    dispatch('deleteModal/open', rule);
  },
};
