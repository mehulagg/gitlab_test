import flash from '~/flash';
import { __, s__, sprintf } from '~/locale';

import axios from '~/lib/utils/axios_utils';
import { visitUrl } from '~/lib/utils/url_utility';

import epicUtils from '../utils/epic_utils';
import { statusType, statusEvent, dateTypes } from '../constants';

import * as types from './mutation_types';

export default {
  setEpicMeta: ({ commit }, meta) => commit(types.SET_EPIC_META, meta),

  setEpicData: ({ commit }, data) => commit(types.SET_EPIC_DATA, data),

  requestEpicStatusChange: ({ commit }) => commit(types.REQUEST_EPIC_STATUS_CHANGE),

  requestEpicStatusChangeSuccess: ({ commit }, data) =>
    commit(types.REQUEST_EPIC_STATUS_CHANGE_SUCCESS, data),

  requestEpicStatusChangeFailure: ({ commit }) => {
    commit(types.REQUEST_EPIC_STATUS_CHANGE_FAILURE);
    flash(__('Unable to update this epic at this time.'));
  },

  triggerIssuableEvent: (_, { isEpicOpen }) => {
    // Ensure that status change is reflected across the page.
    // As `Close`/`Reopen` button is also present under
    // comment form (part of Notes app) We've wrapped
    // call to `$(document).trigger` within `triggerDocumentEvent`
    // for ease of testing
    epicUtils.triggerDocumentEvent('issuable_vue_app:change', isEpicOpen);
    epicUtils.triggerDocumentEvent('issuable:change', isEpicOpen);
  },

  toggleEpicStatus: ({ state, dispatch }, isEpicOpen) => {
    dispatch('requestEpicStatusChange');

    const statusEventType = isEpicOpen ? statusEvent.close : statusEvent.reopen;
    const queryParam = `epic[state_event]=${statusEventType}`;

    axios
      .put(`${state.endpoint}.json?${encodeURI(queryParam)}`)
      .then(({ data }) => {
        dispatch('requestEpicStatusChangeSuccess', data);
        dispatch('triggerIssuableEvent', { isEpicOpen: data.state === statusType.close });
      })
      .catch(() => {
        dispatch('requestEpicStatusChangeFailure');
        dispatch('triggerIssuableEvent', { isEpicOpen: !isEpicOpen });
      });
  },

  toggleSidebarFlag: ({ commit }, sidebarCollapsed) =>
    commit(types.TOGGLE_SIDEBAR, sidebarCollapsed),
  toggleContainerClassAndCookie: (_, sidebarCollapsed) => {
    epicUtils.toggleContainerClass('right-sidebar-expanded');
    epicUtils.toggleContainerClass('right-sidebar-collapsed');

    epicUtils.setCollapsedGutter(sidebarCollapsed);
  },
  toggleSidebar: ({ dispatch }, { sidebarCollapsed }) => {
    dispatch('toggleContainerClassAndCookie', !sidebarCollapsed);
    dispatch('toggleSidebarFlag', !sidebarCollapsed);
  },

  /**
   * Methods to handle toggling Todo from sidebar
   */
  requestEpicTodoToggle: ({ commit }) => commit(types.REQUEST_EPIC_TODO_TOGGLE),
  requestEpicTodoToggleSuccess: ({ commit }, data) =>
    commit(types.REQUEST_EPIC_TODO_TOGGLE_SUCCESS, data),
  requestEpicTodoToggleFailure: ({ commit, state }, data) => {
    commit(types.REQUEST_EPIC_TODO_TOGGLE_FAILURE, data);

    if (state.todoExists) {
      flash(__('There was an error deleting the todo.'));
    } else {
      flash(__('There was an error adding a todo.'));
    }
  },
  triggerTodoToggleEvent: (_, { count }) => {
    epicUtils.triggerDocumentEvent('todo:toggle', count);
  },
  toggleTodo: ({ state, dispatch }) => {
    let reqPromise;

    dispatch('requestEpicTodoToggle');

    if (!state.todoExists) {
      reqPromise = axios.post(state.todoPath, {
        issuable_id: state.epicId,
        issuable_type: 'epic',
      });
    } else {
      reqPromise = axios.delete(state.todoDeletePath);
    }

    reqPromise
      .then(({ data }) => {
        dispatch('triggerTodoToggleEvent', { count: data.count });
        dispatch('requestEpicTodoToggleSuccess', { todoDeletePath: data.delete_path });
      })
      .catch(() => {
        dispatch('requestEpicTodoToggleFailure');
      });
  },

  /**
   * Methods to handle Epic start and due date manipulations from sidebar
   */
  toggleStartDateType: ({ commit }, data) => commit(types.TOGGLE_EPIC_START_DATE_TYPE, data),
  toggleDueDateType: ({ commit }, data) => commit(types.TOGGLE_EPIC_DUE_DATE_TYPE, data),
  requestEpicDateSave: ({ commit }, data) => commit(types.REQUEST_EPIC_DATE_SAVE, data),
  requestEpicDateSaveSuccess: ({ commit }, data) =>
    commit(types.REQUEST_EPIC_DATE_SAVE_SUCCESS, data),
  requestEpicDateSaveFailure: ({ commit }, data) => {
    commit(types.REQUEST_EPIC_DATE_SAVE_FAILURE, data);
    flash(
      sprintf(s__('Epics|An error occurred while saving the %{epicDateType} date'), {
        epicDateType: dateTypes.start === data.dateType ? s__('Epics|start') : s__('Epics|due'),
      }),
    );
  },
  saveDate: ({ state, dispatch }, { dateType, dateTypeIsFixed, newDate }) => {
    const requestBody = {
      [dateType === dateTypes.start ? 'start_date_is_fixed' : 'due_date_is_fixed']: dateTypeIsFixed,
    };

    if (dateTypeIsFixed) {
      requestBody[dateType === dateTypes.start ? 'start_date_fixed' : 'due_date_fixed'] = newDate;
    }

    dispatch('requestEpicDateSave', { dateType });
    axios
      .put(state.endpoint, requestBody)
      .then(() => {
        dispatch('requestEpicDateSaveSuccess', {
          dateType,
          dateTypeIsFixed,
          newDate,
        });
      })
      .catch(() => {
        dispatch('requestEpicDateSaveFailure', {
          dateType,
          dateTypeIsFixed: !dateTypeIsFixed,
        });
      });
  },

  /**
   * Methods to handle Epic subscription (AKA Notifications) toggle from sidebar
   */
  requestEpicSubscriptionToggle: ({ commit }) => commit(types.REQUEST_EPIC_SUBSCRIPTION_TOGGLE),
  requestEpicSubscriptionToggleSuccess: ({ commit }, data) =>
    commit(types.REQUEST_EPIC_SUBSCRIPTION_TOGGLE_SUCCESS, data),
  requestEpicSubscriptionToggleFailure: ({ commit, state }) => {
    commit(types.REQUEST_EPIC_SUBSCRIPTION_TOGGLE_FAILURE);
    if (state.subscribed) {
      flash(__('An error occurred while unsubscribing to notifications.'));
    } else {
      flash(__('An error occurred while subscribing to notifications.'));
    }
  },
  toggleEpicSubscription: ({ state, dispatch }) => {
    dispatch('requestEpicSubscriptionToggle');
    axios
      .post(state.toggleSubscriptionPath)
      .then(() => {
        dispatch('requestEpicSubscriptionToggleSuccess', {
          subscribed: !state.subscribed,
        });
      })
      .catch(() => {
        dispatch('requestEpicSubscriptionToggleFailure');
      });
  },

  /**
   * Methods to handle Epic create from Epics index page
   */
  setEpicCreateTitle: ({ commit }, data) => commit(types.SET_EPIC_CREATE_TITLE, data),
  requestEpicCreate: ({ commit }) => commit(types.REQUEST_EPIC_CREATE),
  requestEpicCreateSuccess: (_, webUrl) => visitUrl(webUrl),
  requestEpicCreateFailure: ({ commit }) => {
    commit(types.REQUEST_EPIC_CREATE_FAILURE);
    flash(s__('Error creating epic'));
  },
  createEpic: ({ state, dispatch }) => {
    dispatch('requestEpicCreate');
    axios
      .post(state.endpoint, {
        title: state.newEpicTitle,
      })
      .then(({ data }) => {
        dispatch('requestEpicCreateSuccess', data.web_url);
      })
      .catch(() => {
        dispatch('requestEpicCreateFailure');
      });
  },
};
