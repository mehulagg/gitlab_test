import { transition } from '../../lib/utils/finite_state_machine';
import { APPLICATION_STATUS, UPDATE_EVENT, INSTALL_EVENT, UNINSTALL_EVENT } from '../constants';

const {
  NO_STATUS,
  SCHEDULED,
  NOT_INSTALLABLE,
  INSTALLABLE,
  INSTALLING,
  INSTALLED,
  ERROR,
  UPDATING,
  UPDATED,
  UPDATE_ERRORED,
  UNINSTALLING,
  UNINSTALL_ERRORED,
  PRE_INSTALLED,
} = APPLICATION_STATUS;

function exitContext(before, event) {
  const contextKey = `${before}:${event}`;
  const extraContext = {
    [`${NO_STATUS}:${ERROR}`]: { installFailed: true },
    [`${NO_STATUS}:${UPDATE_ERRORED}`]: { updateFailed: true },
    [`${NO_STATUS}:${UNINSTALL_ERRORED}`]: { uninstallFailed: true },
    [`${INSTALLABLE}:${INSTALL_EVENT}`]: { installFailed: false },
    [`${INSTALLING}:${ERROR}`]: { installFailed: true },
    [`${INSTALLED}:${UPDATE_EVENT}`]: { updateFailed: false, updateSuccessful: false },
    [`${INSTALLED}:${UNINSTALL_EVENT}`]: { uninstallFailed: false, uninstallSuccessful: false },
    [`${PRE_INSTALLED}:${UPDATE_EVENT}`]: { updateFailed: false, updateSuccessful: false },
    [`${PRE_INSTALLED}:${UNINSTALL_EVENT}`]: { uninstallFailed: false, uninstallSuccessful: false },
    [`${UPDATING}:${UPDATED}`]: { updateSuccessful: true },
    [`${UPDATING}:${UPDATE_ERRORED}`]: { updateFailed: true },
    [`${UNINSTALLING}:${INSTALLABLE}`]: { uninstallSuccessful: true },
    [`${UNINSTALLING}:${UNINSTALL_ERRORED}`]: { uninstallFailed: true },
  };

  return extraContext[contextKey] || {};
}

const states = {
  [NO_STATUS]: {
    on: {
      [SCHEDULED]: INSTALLING,
      [NOT_INSTALLABLE]: NOT_INSTALLABLE,
      [INSTALLABLE]: INSTALLABLE,
      [INSTALLING]: INSTALLING,
      [INSTALLED]: INSTALLED,
      [ERROR]: INSTALLABLE,
      [UPDATING]: UPDATING,
      [UPDATED]: INSTALLED,
      [UPDATE_ERRORED]: INSTALLED,
      [UNINSTALLING]: UNINSTALLING,
      [UNINSTALL_ERRORED]: INSTALLED,
      [PRE_INSTALLED]: PRE_INSTALLED,
    },
  },
  [NOT_INSTALLABLE]: {
    on: {
      [INSTALLABLE]: INSTALLABLE,
    },
  },
  [INSTALLABLE]: {
    on: {
      [INSTALL_EVENT]: INSTALLING,
      [NOT_INSTALLABLE]: NOT_INSTALLABLE,
      // This is possible in artificial environments for E2E testing
      [INSTALLED]: INSTALLED,
    },
  },
  [INSTALLING]: {
    on: {
      [INSTALLED]: INSTALLED,
      [ERROR]: INSTALLABLE,
    },
  },
  [INSTALLED]: {
    on: {
      [UPDATE_EVENT]: UPDATING,
      [NOT_INSTALLABLE]: NOT_INSTALLABLE,
      [UNINSTALL_EVENT]: UNINSTALLING,
    },
  },
  [PRE_INSTALLED]: {
    on: {
      [UPDATE_EVENT]: UPDATING,
      [NOT_INSTALLABLE]: NOT_INSTALLABLE,
      [UNINSTALL_EVENT]: UNINSTALLING,
    },
  },
  [UPDATING]: {
    on: {
      [UPDATED]: INSTALLED,
      [UPDATE_ERRORED]: INSTALLED,
    },
  },
  [UNINSTALLING]: {
    on: {
      [INSTALLABLE]: INSTALLABLE,
      [UNINSTALL_ERRORED]: INSTALLED,
    },
  },
};

/**
 * Determines an application new state based on the application current state
 * and an event. If the application current state cannot handle a given event,
 * the current state is returned.
 *
 * @param {*} application
 * @param {*} event
 */
const transitionApplicationState = (application, event) => {
  const state = transition({ states }, application.status, event);

  return state !== application.status
    ? {
        ...application,
        status: state,
        ...exitContext(application.status, event),
      }
    : application;
};

export default transitionApplicationState;
